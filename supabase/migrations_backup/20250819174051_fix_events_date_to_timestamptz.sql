-- Fix events table: change event_date from DATE to TIMESTAMP WITH TIME ZONE
-- Keep column name as "event_date" but change type to TIMESTAMPTZ

-- Change event_date from DATE to TIMESTAMP WITH TIME ZONE
-- Add new column with TIMESTAMPTZ type
ALTER TABLE public.events ADD COLUMN event_date_new TIMESTAMP WITH TIME ZONE;

-- Convert existing DATE data to TIMESTAMPTZ (set time to midnight in event timezone)
UPDATE public.events 
SET event_date_new = (event_date::TEXT || ' 00:00:00')::TIMESTAMP AT TIME ZONE timezone;

-- Make new column NOT NULL
ALTER TABLE public.events ALTER COLUMN event_date_new SET NOT NULL;

-- Drop old column
ALTER TABLE public.events DROP COLUMN event_date;

-- Rename new column back to event_date
ALTER TABLE public.events RENAME COLUMN event_date_new TO event_date;

-- Also change end_date to TIMESTAMPTZ for consistency
ALTER TABLE public.events ADD COLUMN end_date_new TIMESTAMP WITH TIME ZONE;

-- Convert existing end_date data (only if not null)
UPDATE public.events 
SET end_date_new = CASE 
    WHEN end_date IS NOT NULL THEN (end_date::TEXT || ' 23:59:59')::TIMESTAMP AT TIME ZONE timezone
    ELSE NULL
END;

-- Drop old end_date column
ALTER TABLE public.events DROP COLUMN end_date;

-- Rename new column back to end_date
ALTER TABLE public.events RENAME COLUMN end_date_new TO end_date;

-- Recreate the date indexes
DROP INDEX IF EXISTS idx_events_date;
DROP INDEX IF EXISTS idx_events_end_date;
CREATE INDEX idx_events_date ON public.events(event_date);
CREATE INDEX idx_events_end_date ON public.events(end_date);

-- Update constraint to work with timestamps
ALTER TABLE public.events DROP CONSTRAINT IF EXISTS events_end_date_after_start;
ALTER TABLE public.events ADD CONSTRAINT events_end_date_after_start 
CHECK (end_date IS NULL OR end_date >= event_date);