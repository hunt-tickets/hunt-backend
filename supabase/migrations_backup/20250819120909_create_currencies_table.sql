-- Create currencies table for Hunt Tickets platform
CREATE TABLE public.currencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE, -- Short name (COP, USD)
    name TEXT NOT NULL, -- Long name (Colombian Peso, US Dollar)
    symbol TEXT NOT NULL, -- Currency symbol ($, $)
    decimal_places INTEGER DEFAULT 2,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX idx_currencies_code ON public.currencies(code);
CREATE INDEX idx_currencies_active ON public.currencies(is_active);

-- Enable RLS (Row Level Security)
ALTER TABLE public.currencies ENABLE ROW LEVEL SECURITY;

-- Policy for reading currencies (anyone can see active currencies)
CREATE POLICY "Anyone can view active currencies" 
ON public.currencies 
FOR SELECT 
USING (is_active = true);

-- Policy for authenticated users to see all currencies
CREATE POLICY "Authenticated users can view all currencies" 
ON public.currencies 
FOR SELECT 
TO authenticated 
USING (true);

-- Policy for service role to manage currencies
CREATE POLICY "Service role can manage currencies" 
ON public.currencies 
FOR ALL 
TO service_role 
USING (true);

-- Create trigger for updated_at
CREATE TRIGGER update_currencies_updated_at 
    BEFORE UPDATE ON public.currencies 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();