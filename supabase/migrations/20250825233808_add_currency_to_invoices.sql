-- Add currency column to invoices table
-- Created 2025-08-25

-- Add currency column to invoices table
ALTER TABLE invoices 
ADD COLUMN currency TEXT NOT NULL DEFAULT 'USD';

-- Create index on currency for better query performance
CREATE INDEX idx_invoices_currency ON invoices(currency);