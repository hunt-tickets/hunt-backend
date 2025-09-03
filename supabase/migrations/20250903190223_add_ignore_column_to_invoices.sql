-- Add ignore column to invoices table
ALTER TABLE invoices ADD COLUMN ignore BOOLEAN DEFAULT FALSE;