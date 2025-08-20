-- Create events_payment_settings table
CREATE TABLE events_payment_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL UNIQUE,
  tax BOOLEAN DEFAULT false,
  refund_policy TEXT,
  self_refund BOOLEAN DEFAULT false,
  refundable_amount NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add foreign key constraint to events table
ALTER TABLE events_payment_settings 
ADD CONSTRAINT events_payment_settings_event_id_fkey 
FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;

-- Create index on event_id for efficient queries
CREATE INDEX idx_events_payment_settings_event_id ON events_payment_settings(event_id);

-- Create trigger to auto-update updated_at timestamp
CREATE TRIGGER update_events_payment_settings_updated_at 
    BEFORE UPDATE ON events_payment_settings 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE events_payment_settings ENABLE ROW LEVEL SECURITY;

-- Policy: Allow all users to read payment settings for public events
CREATE POLICY "Anyone can view payment settings" ON events_payment_settings
    FOR SELECT USING (true);

-- Policy: Only authenticated users can insert payment settings
CREATE POLICY "Authenticated users can insert payment settings" ON events_payment_settings
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authenticated users can update payment settings
CREATE POLICY "Authenticated users can update payment settings" ON events_payment_settings
    FOR UPDATE USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authenticated users can delete payment settings
CREATE POLICY "Authenticated users can delete payment settings" ON events_payment_settings
    FOR DELETE USING (auth.role() = 'authenticated');

-- Remove tax column from events table
ALTER TABLE events DROP COLUMN tax;