-- Drop the problematic table if it exists
DROP TABLE IF EXISTS public.events CASCADE;

-- Create events table for Hunt Tickets platform (without special characters)
CREATE TABLE public.events (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    event_date TIMESTAMP WITH TIME ZONE NOT NULL,
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

-- Add indexes for better performance
CREATE INDEX idx_events_date ON public.events(event_date);
CREATE INDEX idx_events_status ON public.events(status);
CREATE INDEX idx_events_category ON public.events(category);
CREATE INDEX idx_events_organizer ON public.events(organizer_id);

-- Enable RLS (Row Level Security)
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

-- Policy for reading events (anyone can see active events)
CREATE POLICY "Anyone can view active events" 
ON public.events 
FOR SELECT 
USING (status = 'active');

-- Policy for authenticated users to see all events
CREATE POLICY "Authenticated users can view all events" 
ON public.events 
FOR SELECT 
TO authenticated 
USING (true);

-- Policy for creating events (authenticated users only)
CREATE POLICY "Authenticated users can create events" 
ON public.events 
FOR INSERT 
TO authenticated 
WITH CHECK (true);

-- Policy for updating events (only organizers)
CREATE POLICY "Organizers can update their events" 
ON public.events 
FOR UPDATE 
TO authenticated 
USING (auth.uid() = organizer_id);

-- Create trigger for updated_at
CREATE TRIGGER update_events_updated_at 
    BEFORE UPDATE ON public.events 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data (no special characters)
INSERT INTO public.events (title, description, event_date, location, price, category, metadata) VALUES
('Concierto Rock Nacional', 'Los mejores exponentes del rock colombiano', '2024-12-15 20:00:00+00', 'Teatro Colon, Bogota', 75000, 'concert', '{"duration": "3 hours", "age_limit": "18+"}'),
('Obra de Teatro Clasica', 'Representacion de Romeo y Julieta', '2024-11-20 19:30:00+00', 'Teatro Nacional, Medellin', 45000, 'theater', '{"duration": "2.5 hours", "intermission": true}'),
('Conferencia Tech 2024', 'Las ultimas tendencias en tecnologia', '2024-10-30 09:00:00+00', 'Centro de Convenciones, Cali', 120000, 'conference', '{"includes_lunch": true, "networking": true}');