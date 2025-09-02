-- Fix multi-language support for currencies table (without special characters)
-- Drop the problematic migration and redo it properly

-- Drop any existing name_i18n column if it exists
ALTER TABLE public.currencies DROP COLUMN IF EXISTS name_i18n;

-- Add the new JSONB column
ALTER TABLE public.currencies ADD COLUMN name_i18n JSONB;

-- Update existing data to JSONB format with Spanish and English (no accents)
UPDATE public.currencies 
SET name_i18n = CASE 
    WHEN code = 'COP' THEN '{"es": "Peso Colombiano", "en": "Colombian Peso"}'::jsonb
    WHEN code = 'USD' THEN '{"es": "Dolar Estadounidense", "en": "US Dollar"}'::jsonb
    ELSE ('{"en": "' || name || '"}')::jsonb
END;

-- Make the new column NOT NULL now that it has data
ALTER TABLE public.currencies ALTER COLUMN name_i18n SET NOT NULL;

-- Drop the old name column
ALTER TABLE public.currencies DROP COLUMN name;

-- Rename the new column to name
ALTER TABLE public.currencies RENAME COLUMN name_i18n TO name;

-- Add a check constraint to ensure at least English is present
ALTER TABLE public.currencies ADD CONSTRAINT currencies_name_has_english 
CHECK (name ? 'en');

-- Add GIN index for better JSONB performance
CREATE INDEX IF NOT EXISTS idx_currencies_name_gin ON public.currencies USING GIN (name);