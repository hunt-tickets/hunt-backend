-- Create events_access_code table
CREATE TABLE events_access_code (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL,
  code TEXT NOT NULL,
  quantity INTEGER DEFAULT 1,
  applies_to JSONB DEFAULT NULL,
  status BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add foreign key constraint to events table
ALTER TABLE events_access_code 
ADD CONSTRAINT events_access_code_event_id_fkey 
FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;

-- Create unique constraint on event_id + code combination
ALTER TABLE events_access_code 
ADD CONSTRAINT events_access_code_event_code_unique 
UNIQUE (event_id, code);

-- Create indexes for efficient queries
CREATE INDEX idx_events_access_code_event_id ON events_access_code(event_id);
CREATE INDEX idx_events_access_code_code ON events_access_code(code);
CREATE INDEX idx_events_access_code_status ON events_access_code(status);

-- Create trigger to auto-update updated_at timestamp
CREATE TRIGGER update_events_access_code_updated_at 
    BEFORE UPDATE ON events_access_code 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE events_access_code ENABLE ROW LEVEL SECURITY;

-- Policy: Allow all users to read active access codes
CREATE POLICY "Anyone can view active access codes" ON events_access_code
    FOR SELECT USING (status = true);

-- Policy: Only authenticated users can insert access codes
CREATE POLICY "Authenticated users can insert access codes" ON events_access_code
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authenticated users can update access codes
CREATE POLICY "Authenticated users can update access codes" ON events_access_code
    FOR UPDATE USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authenticated users can delete access codes
CREATE POLICY "Authenticated users can delete access codes" ON events_access_code
    FOR DELETE USING (auth.role() = 'authenticated');

-- Add status column to events_affiliates table
ALTER TABLE events_affiliates ADD COLUMN status BOOLEAN DEFAULT true;