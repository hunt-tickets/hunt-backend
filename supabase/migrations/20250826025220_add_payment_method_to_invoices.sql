-- Add payment_method column to invoices table
-- Created 2025-08-26

ALTER TABLE invoices 
ADD COLUMN payment_method TEXT;