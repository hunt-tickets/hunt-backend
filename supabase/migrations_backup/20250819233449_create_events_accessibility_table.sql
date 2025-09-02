-- Create events_accessibility table with contact information
-- Table for storing accessibility information and contact details for events

CREATE TABLE public.events_accessibility (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
    contact_name TEXT,
    contact_prefix TEXT,
    contact_number TEXT,
    contact_email TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add constraints for contact fields
ALTER TABLE public.events_accessibility ADD CONSTRAINT events_accessibility_contact_name_length 
CHECK (contact_name IS NULL OR char_length(contact_name) >= 2);

ALTER TABLE public.events_accessibility ADD CONSTRAINT events_accessibility_contact_prefix_format 
CHECK (contact_prefix IS NULL OR contact_prefix ~* '^[+]?[0-9]{1,4}$');

ALTER TABLE public.events_accessibility ADD CONSTRAINT events_accessibility_contact_number_format 
CHECK (contact_number IS NULL OR contact_number ~* '^[0-9]{7,15}$');

ALTER TABLE public.events_accessibility ADD CONSTRAINT events_accessibility_contact_email_format 
CHECK (contact_email IS NULL OR contact_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Create indexes for better performance
CREATE INDEX idx_events_accessibility_event_id ON public.events_accessibility(event_id);
CREATE INDEX idx_events_accessibility_contact_email ON public.events_accessibility(contact_email);
CREATE INDEX idx_events_accessibility_contact_number ON public.events_accessibility(contact_number);

-- Enable RLS (Row Level Security)
ALTER TABLE public.events_accessibility ENABLE ROW LEVEL SECURITY;

-- Create policies for events_accessibility
CREATE POLICY "Anyone can view accessibility info for public events" 
ON public.events_accessibility 
FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.events 
        WHERE events.id = events_accessibility.event_id 
        AND events.privacy = 'public' 
        AND events.status = 'active'
    )
);

CREATE POLICY "Authenticated users can view all accessibility info" 
ON public.events_accessibility 
FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "Authenticated users can manage accessibility info" 
ON public.events_accessibility 
FOR ALL 
TO authenticated 
USING (true);

CREATE POLICY "Service role can manage all accessibility info" 
ON public.events_accessibility 
FOR ALL 
TO service_role 
USING (true);

-- Create trigger for updated_at column
CREATE TRIGGER update_events_accessibility_updated_at 
    BEFORE UPDATE ON public.events_accessibility 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Add unique constraint to ensure one accessibility record per event
ALTER TABLE public.events_accessibility ADD CONSTRAINT events_accessibility_event_id_unique 
UNIQUE (event_id);