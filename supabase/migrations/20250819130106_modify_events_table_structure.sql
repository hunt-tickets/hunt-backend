-- Modify events table structure
-- Change ID to UUID, add timezone, add short_description with 160 char limit

-- Create new events table with UUID and desired structure
CREATE TABLE public.events_new (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    short_description TEXT CHECK (char_length(short_description) <= 160),
    event_date TIMESTAMP WITH TIME ZONE NOT NULL,
    timezone TEXT DEFAULT 'America/Bogota',
    location TEXT NOT NULL,
    max_capacity INTEGER DEFAULT 100,
    current_capacity INTEGER DEFAULT 0,
    price DECIMAL(10,2) DEFAULT 0,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'sold_out', 'cancelled')),
    category TEXT DEFAULT 'general' CHECK (category IN ('concert', 'theater', 'sports', 'conference', 'general')),
    organizer_id UUID,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Copy existing data from old table (if any exists)
INSERT INTO public.events_new (
    title, description, event_date, timezone, location, max_capacity, 
    current_capacity, price, status, category, organizer_id, metadata, created_at, updated_at
)
SELECT 
    title, 
    description, 
    event_date,
    'America/Bogota' as timezone, -- Default timezone for existing records
    location, 
    max_capacity, 
    current_capacity, 
    price, 
    status, 
    category, 
    organizer_id, 
    metadata, 
    created_at, 
    updated_at
FROM public.events;

-- Drop the old table
DROP TABLE public.events CASCADE;

-- Rename new table to events
ALTER TABLE public.events_new RENAME TO events;

-- Recreate indexes for better performance  
CREATE INDEX idx_events_date ON public.events(event_date);
CREATE INDEX idx_events_status ON public.events(status);
CREATE INDEX idx_events_category ON public.events(category);
CREATE INDEX idx_events_organizer ON public.events(organizer_id);
CREATE INDEX idx_events_timezone ON public.events(timezone);

-- Enable RLS (Row Level Security)
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

-- Recreate policies
CREATE POLICY "Anyone can view active events" 
ON public.events 
FOR SELECT 
USING (status = 'active');

CREATE POLICY "Authenticated users can view all events" 
ON public.events 
FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "Authenticated users can create events" 
ON public.events 
FOR INSERT 
TO authenticated 
WITH CHECK (true);

CREATE POLICY "Service role can manage events" 
ON public.events 
FOR ALL 
TO service_role 
USING (true);

-- Create trigger for updated_at
CREATE TRIGGER update_events_updated_at 
    BEFORE UPDATE ON public.events 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();