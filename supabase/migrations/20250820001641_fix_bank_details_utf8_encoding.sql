-- Create bank_details table for Latin America scalability (UTF-8 fixed)
-- Table for storing banking information with multi-country support

-- Create enums for standardized values
CREATE TYPE account_type_enum AS ENUM ('savings', 'checking', 'business', 'other');
CREATE TYPE document_type_enum AS ENUM ('CC', 'CE', 'DNI', 'RUT', 'RFC', 'CPF', 'PASSPORT', 'OTHER');

CREATE TABLE public.bank_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    country_id UUID NOT NULL REFERENCES public.countries(id),
    
    -- Account Information
    account_type account_type_enum NOT NULL DEFAULT 'savings',
    bank_name TEXT NOT NULL,
    account_number TEXT NOT NULL,
    account_holder_name TEXT NOT NULL,
    
    -- Document Information (varies by country)
    document_type document_type_enum NOT NULL,
    document_number TEXT NOT NULL,
    
    -- Banking Codes (varies by country)
    bank_code TEXT, -- Bank code specific to each country
    branch_code TEXT, -- Branch or agency code
    swift_code TEXT, -- For international transfers
    routing_number TEXT, -- Routing number used in some countries
    
    -- Additional country-specific information
    additional_banking_info JSONB DEFAULT '{}',
    
    -- Verification and status
    is_verified BOOLEAN DEFAULT false,
    verification_date TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add constraints for banking fields
ALTER TABLE public.bank_details ADD CONSTRAINT bank_details_account_number_length 
CHECK (char_length(account_number) >= 4 AND char_length(account_number) <= 50);

ALTER TABLE public.bank_details ADD CONSTRAINT bank_details_document_number_length 
CHECK (char_length(document_number) >= 3 AND char_length(document_number) <= 30);

ALTER TABLE public.bank_details ADD CONSTRAINT bank_details_account_holder_name_length 
CHECK (char_length(account_holder_name) >= 2 AND char_length(account_holder_name) <= 100);

ALTER TABLE public.bank_details ADD CONSTRAINT bank_details_bank_name_length 
CHECK (char_length(bank_name) >= 2 AND char_length(bank_name) <= 100);

-- SWIFT code validation (8 or 11 characters)
ALTER TABLE public.bank_details ADD CONSTRAINT bank_details_swift_code_format 
CHECK (swift_code IS NULL OR swift_code ~* '^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');

-- Bank code validation (alphanumeric, 3-10 characters)
ALTER TABLE public.bank_details ADD CONSTRAINT bank_details_bank_code_format 
CHECK (bank_code IS NULL OR bank_code ~* '^[A-Z0-9]{3,10}$');

-- Branch code validation (alphanumeric, 3-10 characters)
ALTER TABLE public.bank_details ADD CONSTRAINT bank_details_branch_code_format 
CHECK (branch_code IS NULL OR branch_code ~* '^[A-Z0-9]{3,10}$');

-- Create indexes for better performance
CREATE INDEX idx_bank_details_profile_id ON public.bank_details(profile_id);
CREATE INDEX idx_bank_details_country_id ON public.bank_details(country_id);
CREATE INDEX idx_bank_details_account_type ON public.bank_details(account_type);
CREATE INDEX idx_bank_details_document_type ON public.bank_details(document_type);
CREATE INDEX idx_bank_details_document_number ON public.bank_details(document_number);
CREATE INDEX idx_bank_details_bank_code ON public.bank_details(bank_code);
CREATE INDEX idx_bank_details_swift_code ON public.bank_details(swift_code);
CREATE INDEX idx_bank_details_is_verified ON public.bank_details(is_verified);
CREATE INDEX idx_bank_details_is_active ON public.bank_details(is_active);

-- GIN index for additional_banking_info JSONB field
CREATE INDEX idx_bank_details_additional_banking_info_gin 
ON public.bank_details USING GIN (additional_banking_info);

-- Enable RLS (Row Level Security)
ALTER TABLE public.bank_details ENABLE ROW LEVEL SECURITY;

-- Create policies for bank_details (highly sensitive data)
CREATE POLICY "Users can view own bank details" 
ON public.bank_details 
FOR SELECT 
TO authenticated 
USING (profile_id IN (SELECT id FROM public.profiles WHERE auth.uid() = id));

CREATE POLICY "Users can insert own bank details" 
ON public.bank_details 
FOR INSERT 
TO authenticated 
WITH CHECK (profile_id IN (SELECT id FROM public.profiles WHERE auth.uid() = id));

CREATE POLICY "Users can update own bank details" 
ON public.bank_details 
FOR UPDATE 
TO authenticated 
USING (profile_id IN (SELECT id FROM public.profiles WHERE auth.uid() = id));

CREATE POLICY "Users can delete own bank details" 
ON public.bank_details 
FOR DELETE 
TO authenticated 
USING (profile_id IN (SELECT id FROM public.profiles WHERE auth.uid() = id));

CREATE POLICY "Service role can manage all bank details" 
ON public.bank_details 
FOR ALL 
TO service_role 
USING (true);

-- Create trigger for updated_at column
CREATE TRIGGER update_bank_details_updated_at 
    BEFORE UPDATE ON public.bank_details 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Add unique constraint for profile + country + account_number combination
-- This prevents duplicate accounts for the same user in the same country
ALTER TABLE public.bank_details ADD CONSTRAINT bank_details_profile_country_account_unique 
UNIQUE (profile_id, country_id, account_number);

-- Add comment explaining the additional_banking_info JSONB usage
COMMENT ON COLUMN public.bank_details.additional_banking_info IS 
'Country-specific banking information stored as JSONB. Examples:
- Colombia: {"cbu": "value", "bank_entity_code": "value"}
- Mexico: {"clabe": "value", "bank_key": "value"}  
- Brazil: {"agencia": "value", "conta": "value", "bank_ispb": "value"}
- Argentina: {"cbu": "value", "alias": "value"}';

COMMENT ON TABLE public.bank_details IS 
'Banking details table designed for Latin America scalability. 
Supports multiple countries with varying banking systems and document types.
Uses JSONB for country-specific additional information.';