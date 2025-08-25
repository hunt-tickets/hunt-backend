-- Add accessibility fields to events_accessibility table
-- Additional fields for comprehensive accessibility information

-- Add text fields for accessibility instructions and information
ALTER TABLE public.events_accessibility ADD COLUMN entry_instructions TEXT;
ALTER TABLE public.events_accessibility ADD COLUMN after_entry_instructions TEXT;
ALTER TABLE public.events_accessibility ADD COLUMN hazards_information TEXT;
ALTER TABLE public.events_accessibility ADD COLUMN toilet_directions TEXT;
ALTER TABLE public.events_accessibility ADD COLUMN accessible_parking TEXT;

-- Add JSONB fields for flexible data storage
ALTER TABLE public.events_accessibility ADD COLUMN extra_information JSONB DEFAULT '{}';
ALTER TABLE public.events_accessibility ADD COLUMN features JSONB DEFAULT '{}';

-- Add constraints for text fields (optional length limits)
ALTER TABLE public.events_accessibility ADD CONSTRAINT events_accessibility_entry_instructions_length 
CHECK (entry_instructions IS NULL OR char_length(entry_instructions) <= 2000);

ALTER TABLE public.events_accessibility ADD CONSTRAINT events_accessibility_after_entry_instructions_length 
CHECK (after_entry_instructions IS NULL OR char_length(after_entry_instructions) <= 2000);

ALTER TABLE public.events_accessibility ADD CONSTRAINT events_accessibility_hazards_information_length 
CHECK (hazards_information IS NULL OR char_length(hazards_information) <= 2000);

ALTER TABLE public.events_accessibility ADD CONSTRAINT events_accessibility_toilet_directions_length 
CHECK (toilet_directions IS NULL OR char_length(toilet_directions) <= 1000);

ALTER TABLE public.events_accessibility ADD CONSTRAINT events_accessibility_accessible_parking_length 
CHECK (accessible_parking IS NULL OR char_length(accessible_parking) <= 1000);

-- Create GIN indexes for JSONB fields to enable efficient queries
CREATE INDEX idx_events_accessibility_extra_information_gin 
ON public.events_accessibility USING GIN (extra_information);

CREATE INDEX idx_events_accessibility_features_gin 
ON public.events_accessibility USING GIN (features);

-- Add indexes for text fields that might be searched
CREATE INDEX idx_events_accessibility_entry_instructions 
ON public.events_accessibility USING GIN (to_tsvector('spanish', entry_instructions));

CREATE INDEX idx_events_accessibility_hazards_information 
ON public.events_accessibility USING GIN (to_tsvector('spanish', hazards_information));