-- Create countries table with link to currencies
-- Table for storing country information and their default currencies

CREATE TABLE public.countries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE, -- ISO 3166-1 alpha-2 code (CO, US, MX)
    name TEXT NOT NULL, -- Country name (Colombia, United States, Mexico)
    phone_prefix TEXT NOT NULL, -- International calling code (+57, +1, +52)
    default_currency_id UUID REFERENCES public.currencies(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add constraints for country fields
ALTER TABLE public.countries ADD CONSTRAINT countries_code_format 
CHECK (code ~* '^[A-Z]{2}$');

ALTER TABLE public.countries ADD CONSTRAINT countries_name_length 
CHECK (char_length(name) >= 2);

ALTER TABLE public.countries ADD CONSTRAINT countries_phone_prefix_format 
CHECK (phone_prefix ~* '^[+][0-9]{1,4}$');

-- Create indexes for better performance
CREATE INDEX idx_countries_code ON public.countries(code);
CREATE INDEX idx_countries_name ON public.countries(name);
CREATE INDEX idx_countries_phone_prefix ON public.countries(phone_prefix);
CREATE INDEX idx_countries_currency_id ON public.countries(default_currency_id);
CREATE INDEX idx_countries_active ON public.countries(is_active);

-- Enable RLS (Row Level Security)
ALTER TABLE public.countries ENABLE ROW LEVEL SECURITY;

-- Create policies for countries
CREATE POLICY "Anyone can view active countries" 
ON public.countries 
FOR SELECT 
USING (is_active = true);

CREATE POLICY "Authenticated users can view all countries" 
ON public.countries 
FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "Service role can manage all countries" 
ON public.countries 
FOR ALL 
TO service_role 
USING (true);

-- Create trigger for updated_at column
CREATE TRIGGER update_countries_updated_at 
    BEFORE UPDATE ON public.countries 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Insert initial country data with currency links
INSERT INTO public.countries (code, name, phone_prefix, default_currency_id, is_active) 
SELECT 
    country_data.code,
    country_data.name,
    country_data.phone_prefix,
    c.id,
    country_data.is_active
FROM (
    VALUES 
        ('CO', 'Colombia', '+57', 'COP', true),
        ('US', 'United States', '+1', 'USD', true),
        ('MX', 'Mexico', '+52', 'USD', true)
) AS country_data(code, name, phone_prefix, currency_code, is_active)
LEFT JOIN public.currencies c ON c.code = country_data.currency_code
WHERE NOT EXISTS (
    SELECT 1 FROM public.countries WHERE code = country_data.code
);