-- Add applys_to JSONB column to discount_codes table
ALTER TABLE discount_codes ADD COLUMN applys_to JSONB;

-- Add birthdate column to profiles table
ALTER TABLE profiles ADD COLUMN birthdate DATE;

-- Remove company_name and company_id columns from profiles table
ALTER TABLE profiles DROP COLUMN company_name;
ALTER TABLE profiles DROP COLUMN company_id;