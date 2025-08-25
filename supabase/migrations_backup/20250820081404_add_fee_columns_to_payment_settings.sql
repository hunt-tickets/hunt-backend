-- Create fee_payment enum type
CREATE TYPE fee_payment_type AS ENUM ('absorver_fees', 'dividir_fee', 'pasar_fees');

-- Add fee columns to events_payment_settings table
ALTER TABLE events_payment_settings ADD COLUMN variable_fee NUMERIC DEFAULT 0;
ALTER TABLE events_payment_settings ADD COLUMN fixed_fee NUMERIC DEFAULT 0;
ALTER TABLE events_payment_settings ADD COLUMN fee_payment fee_payment_type DEFAULT 'absorver_fees';