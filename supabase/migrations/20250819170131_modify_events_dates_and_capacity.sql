-- Modify events table: change event_date to DATE, add end_date, remove capacity fields
-- Change event_date from TIMESTAMP WITH TIME ZONE to DATE
-- Add end_date as DATE
-- Remove max_capacity and current_capacity columns
-- Rename title to name, add keywords JSONB, add frequency enum

-- Add end_date column first
ALTER TABLE public.events ADD COLUMN end_date DATE;

-- Rename title to name
ALTER TABLE public.events RENAME COLUMN title TO name;

-- Add keywords JSONB column for user labels
ALTER TABLE public.events ADD COLUMN keywords JSONB DEFAULT '[]';

-- Create frequency enum type
CREATE TYPE frequency_type AS ENUM ('single', 'recurring');

-- Add frequency column with enum
ALTER TABLE public.events ADD COLUMN frequency frequency_type DEFAULT 'single';

-- Change event_date from TIMESTAMP WITH TIME ZONE to DATE
-- First add new column
ALTER TABLE public.events ADD COLUMN event_date_new DATE;

-- Copy existing data converting timestamp to date
UPDATE public.events SET event_date_new = event_date::DATE;

-- Make new column NOT NULL
ALTER TABLE public.events ALTER COLUMN event_date_new SET NOT NULL;

-- Drop old column
ALTER TABLE public.events DROP COLUMN event_date;

-- Rename new column
ALTER TABLE public.events RENAME COLUMN event_date_new TO event_date;

-- Remove capacity columns
ALTER TABLE public.events DROP COLUMN IF EXISTS max_capacity;
ALTER TABLE public.events DROP COLUMN IF EXISTS current_capacity;

-- Recreate the date index
DROP INDEX IF EXISTS idx_events_date;
CREATE INDEX idx_events_date ON public.events(event_date);

-- Add index for end_date
CREATE INDEX idx_events_end_date ON public.events(end_date);

-- Add index for keywords JSONB
CREATE INDEX idx_events_keywords_gin ON public.events USING GIN (keywords);

-- Add index for frequency
CREATE INDEX idx_events_frequency ON public.events(frequency);

-- Add constraint to ensure end_date is after or equal to event_date
ALTER TABLE public.events ADD CONSTRAINT events_end_date_after_start 
CHECK (end_date IS NULL OR end_date >= event_date);