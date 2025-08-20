-- Create producers table
CREATE TABLE producers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  website TEXT,
  instagram TEXT,
  facebook TEXT,
  x TEXT,
  spotify TEXT,
  soundcloud TEXT,
  tiktok TEXT,
  linkedin TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on name for efficient searching
CREATE INDEX idx_producers_name ON producers(name);

-- Create function to automatically update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to auto-update updated_at timestamp
CREATE TRIGGER update_producers_updated_at 
    BEFORE UPDATE ON producers 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE producers ENABLE ROW LEVEL SECURITY;

-- Policy: Allow all users to read producers (public data)
CREATE POLICY "Anyone can view producers" ON producers
    FOR SELECT USING (true);

-- Policy: Only authenticated users can insert producers
CREATE POLICY "Authenticated users can insert producers" ON producers
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Users can update their own producers (if we add user ownership later)
-- For now, allowing authenticated users to update any producer
CREATE POLICY "Authenticated users can update producers" ON producers
    FOR UPDATE USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Policy: Users can delete their own producers (if we add user ownership later)
-- For now, allowing authenticated users to delete any producer
CREATE POLICY "Authenticated users can delete producers" ON producers
    FOR DELETE USING (auth.role() = 'authenticated');