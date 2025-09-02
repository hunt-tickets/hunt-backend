-- Create default public storage bucket for Hunt Tickets
-- This bucket will store publicly accessible files like event images, logos, etc.

-- Create the default bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'default',
    'default',
    true,
    52428800, -- 50MB file size limit
    ARRAY[
        'image/jpeg',
        'image/jpg', 
        'image/png',
        'image/webp',
        'image/gif',
        'application/pdf',
        'text/plain',
        'text/csv'
    ]
);

-- Create storage policies for the default bucket
-- Allow anyone to view files in the public bucket
CREATE POLICY "Public bucket - anyone can view files"
ON storage.objects
FOR SELECT
USING (bucket_id = 'default');

-- Allow authenticated users to upload files
CREATE POLICY "Authenticated users can upload to default bucket"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'default');

-- Allow authenticated users to update their own files
CREATE POLICY "Authenticated users can update own files in default bucket"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'default' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow authenticated users to delete their own files
CREATE POLICY "Authenticated users can delete own files in default bucket"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'default' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow service role to manage all files in default bucket
CREATE POLICY "Service role can manage all files in default bucket"
ON storage.objects
FOR ALL
TO service_role
USING (bucket_id = 'default');