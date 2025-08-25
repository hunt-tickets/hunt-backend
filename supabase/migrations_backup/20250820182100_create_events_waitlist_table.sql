-- Create ticket_trigger enum type
CREATE TYPE ticket_trigger_type AS ENUM ('automatic', 'manually');

-- Create events_waitlist table
CREATE TABLE events_waitlist (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL UNIQUE,
  status BOOLEAN DEFAULT false,
  total_capacity BOOLEAN DEFAULT false,
  tickets_sold_out BOOLEAN DEFAULT false,
  applys_to JSONB DEFAULT NULL,
  max_capacity NUMERIC DEFAULT NULL,
  ticket_trigger ticket_trigger_type DEFAULT 'automatic',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add foreign key constraint to events table
ALTER TABLE events_waitlist 
ADD CONSTRAINT events_waitlist_event_id_fkey 
FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;

-- Create index on event_id for efficient queries
CREATE INDEX idx_events_waitlist_event_id ON events_waitlist(event_id);

-- Create index on status for filtering active waitlists
CREATE INDEX idx_events_waitlist_status ON events_waitlist(status);

-- Create trigger to auto-update updated_at timestamp
CREATE TRIGGER update_events_waitlist_updated_at 
    BEFORE UPDATE ON events_waitlist 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE events_waitlist ENABLE ROW LEVEL SECURITY;

-- Policy: Allow all users to read waitlist settings
CREATE POLICY "Anyone can view waitlist settings" ON events_waitlist
    FOR SELECT USING (true);

-- Policy: Only authenticated users can insert waitlist settings
CREATE POLICY "Authenticated users can insert waitlist settings" ON events_waitlist
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authenticated users can update waitlist settings
CREATE POLICY "Authenticated users can update waitlist settings" ON events_waitlist
    FOR UPDATE USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authenticated users can delete waitlist settings
CREATE POLICY "Authenticated users can delete waitlist settings" ON events_waitlist
    FOR DELETE USING (auth.role() = 'authenticated');