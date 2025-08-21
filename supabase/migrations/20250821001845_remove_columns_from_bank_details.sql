-- Remove specified columns from bank_details table
-- Clean up unnecessary banking fields for simplified structure

-- Step 1: Drop related indexes first to avoid conflicts
DROP INDEX IF EXISTS idx_bank_details_bank_code;
DROP INDEX IF EXISTS idx_bank_details_swift_code;
DROP INDEX IF EXISTS idx_bank_details_is_verified;
DROP INDEX IF EXISTS idx_bank_details_is_active;

-- Step 2: Drop constraints related to the columns being removed
ALTER TABLE public.bank_details DROP CONSTRAINT IF EXISTS bank_details_swift_code_format;
ALTER TABLE public.bank_details DROP CONSTRAINT IF EXISTS bank_details_bank_code_format;
ALTER TABLE public.bank_details DROP CONSTRAINT IF EXISTS bank_details_branch_code_format;

-- Step 3: Remove banking code columns
ALTER TABLE public.bank_details DROP COLUMN IF EXISTS bank_code;
ALTER TABLE public.bank_details DROP COLUMN IF EXISTS branch_code;
ALTER TABLE public.bank_details DROP COLUMN IF EXISTS swift_code;
ALTER TABLE public.bank_details DROP COLUMN IF EXISTS routing_number;

-- Step 4: Remove verification and status columns
ALTER TABLE public.bank_details DROP COLUMN IF EXISTS is_verified;
ALTER TABLE public.bank_details DROP COLUMN IF EXISTS verification_date;
ALTER TABLE public.bank_details DROP COLUMN IF EXISTS is_active;

-- Step 5: Add comment about simplified structure
COMMENT ON TABLE public.bank_details IS 
'Simplified banking details table for Latin America scalability. 
Contains core banking information: account details, document info, and country-specific data in JSONB.
Removed: bank codes, verification status, and activity status for streamlined structure.';