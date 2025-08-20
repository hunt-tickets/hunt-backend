-- Create automatic_discounts table
CREATE TABLE automatic_discounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  automatic_type TEXT NOT NULL,
  filter JSONB,
  discount_type discount_code_type NOT NULL,
  amount NUMERIC NOT NULL,
  applys_to JSONB,
  quantity INTEGER DEFAULT 1,
  max_usage INTEGER DEFAULT 1,
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ NOT NULL,
  status BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on name for efficient searching
CREATE INDEX idx_automatic_discounts_name ON automatic_discounts(name);

-- Create index on automatic_type for filtering
CREATE INDEX idx_automatic_discounts_type ON automatic_discounts(automatic_type);

-- Create index on status and date range for active discount queries
CREATE INDEX idx_automatic_discounts_active ON automatic_discounts(status, start_at, end_at);

-- Create trigger to auto-update updated_at timestamp
CREATE TRIGGER update_automatic_discounts_updated_at 
    BEFORE UPDATE ON automatic_discounts 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE automatic_discounts ENABLE ROW LEVEL SECURITY;

-- Policy: Allow all users to read active automatic discounts (public data)
CREATE POLICY "Anyone can view active automatic discounts" ON automatic_discounts
    FOR SELECT USING (status = true AND start_at <= NOW() AND end_at >= NOW());

-- Policy: Only authenticated users can insert automatic discounts
CREATE POLICY "Authenticated users can insert automatic discounts" ON automatic_discounts
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authenticated users can update automatic discounts
CREATE POLICY "Authenticated users can update automatic discounts" ON automatic_discounts
    FOR UPDATE USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authenticated users can delete automatic discounts
CREATE POLICY "Authenticated users can delete automatic discounts" ON automatic_discounts
    FOR DELETE USING (auth.role() = 'authenticated');