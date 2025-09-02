-- Add support and policy columns to countries table
ALTER TABLE countries ADD COLUMN whatsapp_support_phone TEXT;
ALTER TABLE countries ADD COLUMN support_email TEXT;
ALTER TABLE countries ADD COLUMN refund_policy_url TEXT;
ALTER TABLE countries ADD COLUMN terms_of_service_url TEXT;
ALTER TABLE countries ADD COLUMN privacy_policy_url TEXT;