-- Remove price and metadata columns, add privacy enum
-- Final cleanup of events table structure

-- Create privacy enum type
CREATE TYPE privacy_type AS ENUM ('public', 'private');

-- Create new events table with final structure
CREATE TABLE public.events_final (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    short_description TEXT CHECK (char_length(short_description) <= 160),
    description TEXT,
    event_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE,
    timezone TEXT DEFAULT 'America/Bogota',
    status event_status_type DEFAULT 'draft',
    category TEXT DEFAULT 'general' CHECK (category IN ('concert', 'theater', 'sports', 'conference', 'general')),
    frequency frequency_type DEFAULT 'single',
    privacy privacy_type DEFAULT 'public',
    keywords JSONB DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Copy existing data from current table (excluding price and metadata)
INSERT INTO public.events_final (
    id, name, short_description, description, event_date, end_date, timezone, 
    status, category, frequency, keywords, created_at, updated_at
)
SELECT 
    id,
    name, 
    short_description,
    description, 
    event_date,
    end_date,
    timezone,
    status,
    category, 
    frequency,
    keywords,
    created_at, 
    updated_at
FROM public.events;

-- Drop the old table with all its constraints and indexes
DROP TABLE public.events CASCADE;

-- Rename new table to events
ALTER TABLE public.events_final RENAME TO events;

-- Recreate indexes for better performance  
CREATE INDEX idx_events_date ON public.events(event_date);
CREATE INDEX idx_events_end_date ON public.events(end_date);
CREATE INDEX idx_events_status ON public.events(status);
CREATE INDEX idx_events_category ON public.events(category);
CREATE INDEX idx_events_frequency ON public.events(frequency);
CREATE INDEX idx_events_privacy ON public.events(privacy);
CREATE INDEX idx_events_keywords_gin ON public.events USING GIN (keywords);

-- Enable RLS (Row Level Security)
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

-- Recreate policies (updated for privacy)
CREATE POLICY "Anyone can view public active events" 
ON public.events 
FOR SELECT 
USING (status = 'active' AND privacy = 'public');

CREATE POLICY "Authenticated users can view all public events" 
ON public.events 
FOR SELECT 
TO authenticated 
USING (privacy = 'public');

CREATE POLICY "Authenticated users can view all events they created" 
ON public.events 
FOR SELECT 
TO authenticated 
USING (true); -- Will need user association later

CREATE POLICY "Authenticated users can create events" 
ON public.events 
FOR INSERT 
TO authenticated 
WITH CHECK (true);

CREATE POLICY "Service role can manage all events" 
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