-- Create enum for refund status
CREATE TYPE refund_status AS ENUM ('pending', 'approved', 'rejected', 'processed');

-- Create refunds table
CREATE TABLE refunds (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    order_id TEXT NOT NULL,
    description TEXT,
    bank_information JSONB,
    status refund_status DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE refunds ENABLE ROW LEVEL SECURITY;

-- Add indexes for better performance
CREATE INDEX idx_refunds_order_id ON refunds(order_id);
CREATE INDEX idx_refunds_email ON refunds(email);
CREATE INDEX idx_refunds_status ON refunds(status);
CREATE INDEX idx_refunds_created_at ON refunds(created_at);

-- Add trigger for updated_at
CREATE TRIGGER set_refunds_updated_at
    BEFORE UPDATE ON refunds
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();