-- Create events_affiliates table
CREATE TABLE events_affiliates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL,
  code TEXT NOT NULL,
  url TEXT NOT NULL,
  discount_codes JSONB DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add foreign key constraint to events table
ALTER TABLE events_affiliates 
ADD CONSTRAINT events_affiliates_event_id_fkey 
FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;

-- Create unique constraint on event_id + code combination
ALTER TABLE events_affiliates 
ADD CONSTRAINT events_affiliates_event_code_unique 
UNIQUE (event_id, code);

-- Create indexes for efficient queries
CREATE INDEX idx_events_affiliates_event_id ON events_affiliates(event_id);
CREATE INDEX idx_events_affiliates_code ON events_affiliates(code);

-- Create trigger to auto-update updated_at timestamp
CREATE TRIGGER update_events_affiliates_updated_at 
    BEFORE UPDATE ON events_affiliates 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE events_affiliates ENABLE ROW LEVEL SECURITY;

-- Policy: Allow all users to read affiliates (for public referral tracking)
CREATE POLICY "Anyone can view affiliates" ON events_affiliates
    FOR SELECT USING (true);

-- Policy: Only authenticated users can insert affiliates
CREATE POLICY "Authenticated users can insert affiliates" ON events_affiliates
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authenticated users can update affiliates
CREATE POLICY "Authenticated users can update affiliates" ON events_affiliates
    FOR UPDATE USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authenticated users can delete affiliates
CREATE POLICY "Authenticated users can delete affiliates" ON events_affiliates
    FOR DELETE USING (auth.role() = 'authenticated');