-- Create invoices table
-- Created 2025-08-25

-- Create invoices table
CREATE TABLE invoices (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    paid_at TIMESTAMPTZ,
    company_name TEXT NOT NULL,
    description TEXT,
    subtotal NUMERIC NOT NULL,
    tax NUMERIC NOT NULL DEFAULT 0,
    total NUMERIC NOT NULL,
    invoice_to TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    
    -- Primary key
    CONSTRAINT invoices_pkey PRIMARY KEY (id),
    
    -- Check constraints
    CONSTRAINT check_subtotal_positive CHECK (subtotal >= 0),
    CONSTRAINT check_tax_non_negative CHECK (tax >= 0),
    CONSTRAINT check_total_positive CHECK (total >= 0)
);

-- Enable RLS on invoices table
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for invoices table
CREATE POLICY "Authenticated users can view their own invoices" ON invoices 
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can create invoices" ON invoices 
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update their own invoices" ON invoices 
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Create performance indexes
CREATE INDEX idx_invoices_company_name ON invoices(company_name);
CREATE INDEX idx_invoices_created_at ON invoices(created_at);
CREATE INDEX idx_invoices_paid_at ON invoices(paid_at);
CREATE INDEX idx_invoices_total ON invoices(total);

-- Create trigger to automatically update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_invoices_updated_at 
    BEFORE UPDATE ON invoices 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();