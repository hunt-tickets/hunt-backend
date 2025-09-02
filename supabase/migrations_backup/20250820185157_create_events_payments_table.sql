-- Create events_payments table
CREATE TABLE events_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL,
  payment_date TIMESTAMPTZ NOT NULL,
  reference TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  currency_id UUID NOT NULL,
  bank_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add foreign key constraints
ALTER TABLE events_payments 
ADD CONSTRAINT events_payments_event_id_fkey 
FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;

ALTER TABLE events_payments 
ADD CONSTRAINT events_payments_currency_id_fkey 
FOREIGN KEY (currency_id) REFERENCES currencies(id) ON DELETE RESTRICT;

ALTER TABLE events_payments 
ADD CONSTRAINT events_payments_bank_id_fkey 
FOREIGN KEY (bank_id) REFERENCES bank_details(id) ON DELETE RESTRICT;

-- Create indexes for efficient queries
CREATE INDEX idx_events_payments_event_id ON events_payments(event_id);
CREATE INDEX idx_events_payments_payment_date ON events_payments(payment_date);
CREATE INDEX idx_events_payments_reference ON events_payments(reference);
CREATE INDEX idx_events_payments_currency_id ON events_payments(currency_id);
CREATE INDEX idx_events_payments_bank_id ON events_payments(bank_id);

-- Create trigger to auto-update updated_at timestamp
CREATE TRIGGER update_events_payments_updated_at 
    BEFORE UPDATE ON events_payments 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE events_payments ENABLE ROW LEVEL SECURITY;

-- Policy: Only authenticated users can view payments
CREATE POLICY "Authenticated users can view payments" ON events_payments
    FOR SELECT USING (auth.role() = 'authenticated');

-- Policy: Only authenticated users can insert payments
CREATE POLICY "Authenticated users can insert payments" ON events_payments
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Only authenticated users can update payments
CREATE POLICY "Authenticated users can update payments" ON events_payments
    FOR UPDATE USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Policy: Only authenticated users can delete payments
CREATE POLICY "Authenticated users can delete payments" ON events_payments
    FOR DELETE USING (auth.role() = 'authenticated');