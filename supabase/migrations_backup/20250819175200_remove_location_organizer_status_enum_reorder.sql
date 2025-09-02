-- Remove location and organizer_id, make status enum with default draft, reorder columns
-- Create new events table with proper column order and structure

-- Create status enum type
CREATE TYPE event_status_type AS ENUM ('draft', 'active', 'inactive', 'sold_out', 'cancelled');

-- Create new events table with desired structure and column order
CREATE TABLE public.events_new (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    short_description TEXT CHECK (char_length(short_description) <= 160),
    description TEXT,
    event_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE,
    timezone TEXT DEFAULT 'America/Bogota',
    price DECIMAL(10,2) DEFAULT 0,
    status event_status_type DEFAULT 'draft',
    category TEXT DEFAULT 'general' CHECK (category IN ('concert', 'theater', 'sports', 'conference', 'general')),
    frequency frequency_type DEFAULT 'single',
    keywords JSONB DEFAULT '[]',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Copy existing data from old table (excluding location and organizer_id)
INSERT INTO public.events_new (
    id, name, short_description, description, event_date, end_date, timezone, 
    price, status, category, frequency, keywords, metadata, created_at, updated_at
)
SELECT 
    id,
    name, 
    short_description,
    description, 
    event_date,
    end_date,
    timezone,
    price, 
    CASE 
        WHEN status = 'active' THEN 'active'::event_status_type
        WHEN status = 'inactive' THEN 'inactive'::event_status_type
        WHEN status = 'sold_out' THEN 'sold_out'::event_status_type
        WHEN status = 'cancelled' THEN 'cancelled'::event_status_type
        ELSE 'draft'::event_status_type
    END as status,
    category, 
    frequency,
    keywords,
    metadata, 
    created_at, 
    updated_at
FROM public.events;

-- Drop the old table with all its constraints and indexes
DROP TABLE public.events CASCADE;

-- Rename new table to events
ALTER TABLE public.events_new RENAME TO events;

-- Recreate indexes for better performance  
CREATE INDEX idx_events_date ON public.events(event_date);
CREATE INDEX idx_events_end_date ON public.events(end_date);
CREATE INDEX idx_events_status ON public.events(status);
CREATE INDEX idx_events_category ON public.events(category);
CREATE INDEX idx_events_frequency ON public.events(frequency);
CREATE INDEX idx_events_keywords_gin ON public.events USING GIN (keywords);

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

-- Add constraint to ensure end_date is after or equal to event_date
ALTER TABLE public.events ADD CONSTRAINT events_end_date_after_start 
CHECK (end_date IS NULL OR end_date >= event_date);