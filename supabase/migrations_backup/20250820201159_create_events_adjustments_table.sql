-- Create adjustment_type enum
CREATE TYPE adjustment_type AS ENUM ('debit', 'credit', 'refund', 'fee', 'penalty', 'bonus');

-- Create events_adjustments table
CREATE TABLE events_adjustments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  adjustment_type adjustment_type NOT NULL,
  amount NUMERIC NOT NULL,
  currency_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add foreign key constraints
ALTER TABLE events_adjustments 
ADD CONSTRAINT events_adjustments_event_id_fkey 
FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;

ALTER TABLE events_adjustments 
ADD CONSTRAINT events_adjustments_currency_id_fkey 
FOREIGN KEY (currency_id) REFERENCES currencies(id) ON DELETE RESTRICT;

-- Create indexes for efficient queries
CREATE INDEX idx_events_adjustments_event_id ON events_adjustments(event_id);
CREATE INDEX idx_events_adjustments_date ON events_adjustments(date);
CREATE INDEX idx_events_adjustments_type ON events_adjustments(adjustment_type);

-- Create trigger to auto-update updated_at timestamp
CREATE TRIGGER update_events_adjustments_updated_at 
    BEFORE UPDATE ON events_adjustments 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE events_adjustments ENABLE ROW LEVEL SECURITY;

-- Policy: Only authenticated users can view adjustments
CREATE POLICY "Authenticated users can view adjustments" ON events_adjustments
    FOR SELECT USING (auth.role() = 'authenticated');

-- Policy: Only authenticated users can insert adjustments
CREATE POLICY "Authenticated users can insert adjustments" ON events_adjustments
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Only authenticated users can update adjustments
CREATE POLICY "Authenticated users can update adjustments" ON events_adjustments
    FOR UPDATE USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Policy: Only authenticated users can delete adjustments
CREATE POLICY "Authenticated users can delete adjustments" ON events_adjustments
    FOR DELETE USING (auth.role() = 'authenticated');