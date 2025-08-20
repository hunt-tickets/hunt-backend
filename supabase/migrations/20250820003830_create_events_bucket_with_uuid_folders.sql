-- Create events storage bucket with UUID folder structure
-- Each event gets its own folder named with events.id (UUID)
-- This creates a mirror structure: /events/{event_id}/

-- Create the events bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'events',
    'events',
    true,
    104857600, -- 100MB file size limit (larger for event content)
    ARRAY[
        'image/jpeg',
        'image/jpg', 
        'image/png',
        'image/webp',
        'image/gif',
        'image/svg+xml',
        'application/pdf',
        'text/plain',
        'text/csv',
        'video/mp4',
        'video/webm',
        'audio/mpeg',
        'audio/wav'
    ]
);

-- Create storage policies for the events bucket
-- Allow anyone to view files in public events
CREATE POLICY "Public access to active public events files"
ON storage.objects
FOR SELECT
USING (
    bucket_id = 'events' 
    AND EXISTS (
        SELECT 1 FROM public.events 
        WHERE events.id::text = (storage.foldername(name))[1]
        AND events.status = 'active'
        AND events.privacy = 'public'
    )
);

-- Allow authenticated users to view all event files
CREATE POLICY "Authenticated users can view all events files"
ON storage.objects
FOR SELECT
TO authenticated
USING (
    bucket_id = 'events'
    AND EXISTS (
        SELECT 1 FROM public.events 
        WHERE events.id::text = (storage.foldername(name))[1]
    )
);

-- Allow authenticated users to upload files to events (event creators/organizers)
CREATE POLICY "Event creators can upload to their events"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'events'
    AND EXISTS (
        SELECT 1 FROM public.events 
        WHERE events.id::text = (storage.foldername(name))[1]
        -- Add event ownership check here when user association is implemented
    )
);

-- Allow authenticated users to update files in their events
CREATE POLICY "Event creators can update their events files"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
    bucket_id = 'events'
    AND EXISTS (
        SELECT 1 FROM public.events 
        WHERE events.id::text = (storage.foldername(name))[1]
        -- Add event ownership check here when user association is implemented
    )
);

-- Allow authenticated users to delete files in their events
CREATE POLICY "Event creators can delete their events files"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'events'
    AND EXISTS (
        SELECT 1 FROM public.events 
        WHERE events.id::text = (storage.foldername(name))[1]
        -- Add event ownership check here when user association is implemented
    )
);

-- Allow service role to manage all files in events bucket
CREATE POLICY "Service role can manage all events files"
ON storage.objects
FOR ALL
TO service_role
USING (bucket_id = 'events');

-- Function to create a placeholder file when a new event is created
-- This ensures the folder structure exists for each event
CREATE OR REPLACE FUNCTION create_event_storage_folder()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a placeholder file to create the folder structure
    -- The file will be named .gitkeep to maintain folder structure
    INSERT INTO storage.objects (bucket_id, name, owner, metadata)
    VALUES (
        'events',
        NEW.id::text || '/.gitkeep',
        auth.uid(),
        '{"content-type": "text/plain"}'::jsonb
    );
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail the event creation
        RAISE WARNING 'Failed to create storage folder for event %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create folder when event is created
CREATE TRIGGER create_event_storage_folder_trigger
    AFTER INSERT ON public.events
    FOR EACH ROW
    EXECUTE FUNCTION create_event_storage_folder();

-- Create folders for existing events
-- Insert placeholder files for all existing events
INSERT INTO storage.objects (bucket_id, name, metadata)
SELECT 
    'events' as bucket_id,
    events.id::text || '/.gitkeep' as name,
    '{"content-type": "text/plain"}'::jsonb as metadata
FROM public.events
WHERE NOT EXISTS (
    SELECT 1 FROM storage.objects 
    WHERE bucket_id = 'events' 
    AND name = events.id::text || '/.gitkeep'
);

-- Add helpful comments
COMMENT ON TRIGGER create_event_storage_folder_trigger ON public.events IS 
'Automatically creates a storage folder (via .gitkeep file) when a new event is created. 
This ensures each event has its own UUID-named folder in the events bucket.';

COMMENT ON FUNCTION create_event_storage_folder() IS 
'Creates a placeholder .gitkeep file to establish folder structure for new events.
Folder structure: /events/{event_id}/.gitkeep';

-- Create an index to optimize storage policy lookups
CREATE INDEX IF NOT EXISTS idx_events_id_status_privacy 
ON public.events(id, status, privacy);