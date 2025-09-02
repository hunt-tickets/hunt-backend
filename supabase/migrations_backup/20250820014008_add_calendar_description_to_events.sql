-- Add calendar_description column to events table
-- For storing description text specifically for calendar integration

-- Add calendar_description column
ALTER TABLE public.events ADD COLUMN calendar_description TEXT;

-- Add constraint for calendar_description length (optional, reasonable limit)
ALTER TABLE public.events ADD CONSTRAINT events_calendar_description_length 
CHECK (calendar_description IS NULL OR char_length(calendar_description) <= 1000);

-- Create index for calendar_description searches
CREATE INDEX idx_events_calendar_description 
ON public.events USING GIN (to_tsvector('english', calendar_description));

-- Add helpful comment
COMMENT ON COLUMN public.events.calendar_description IS 
'Description text specifically for calendar integration. Used when adding events to calendar applications. 
Max length: 1000 characters.';