-- Add case_number to refunds table
-- Created 2025-08-26

-- Add case_number column to refunds table
ALTER TABLE refunds 
ADD COLUMN case_number TEXT;

-- Function to generate alphanumeric case number
CREATE OR REPLACE FUNCTION generate_case_number()
RETURNS TEXT AS $$
DECLARE
    chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    result TEXT := 'RF-';
    i INTEGER;
    case_exists BOOLEAN;
    attempts INTEGER := 0;
    max_attempts INTEGER := 100;
BEGIN
    LOOP
        -- Reset result for each attempt
        result := 'RF-';
        
        -- Generate 6 random characters
        FOR i IN 1..6 LOOP
            result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
        END LOOP;
        
        -- Check if case number already exists
        SELECT EXISTS(
            SELECT 1 FROM refunds WHERE case_number = result
        ) INTO case_exists;
        
        -- If unique, return the case number
        IF NOT case_exists THEN
            RETURN result;
        END IF;
        
        -- Increment attempts and check limit
        attempts := attempts + 1;
        IF attempts >= max_attempts THEN
            RAISE EXCEPTION 'Unable to generate unique case number after % attempts', max_attempts;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to set case number before insert
CREATE OR REPLACE FUNCTION set_case_number()
RETURNS TRIGGER AS $$
BEGIN
    -- Only generate if case_number is not provided
    IF NEW.case_number IS NULL OR NEW.case_number = '' THEN
        NEW.case_number := generate_case_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-generate case numbers
CREATE TRIGGER trigger_set_case_number
    BEFORE INSERT ON refunds
    FOR EACH ROW
    EXECUTE FUNCTION set_case_number();

-- Make case_number NOT NULL and UNIQUE
ALTER TABLE refunds 
ALTER COLUMN case_number SET NOT NULL;

ALTER TABLE refunds 
ADD CONSTRAINT case_number_unique UNIQUE (case_number);

-- Create index for performance
CREATE INDEX idx_refunds_case_number ON refunds(case_number);