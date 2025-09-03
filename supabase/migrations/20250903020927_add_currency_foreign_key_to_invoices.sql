-- Add foreign key constraint to invoices.currency referencing currencies.code
ALTER TABLE invoices
ADD CONSTRAINT fk_invoices_currency
FOREIGN KEY (currency) REFERENCES currencies (code);