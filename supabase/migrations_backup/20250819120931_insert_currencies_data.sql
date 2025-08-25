-- Insert initial currency data for Hunt Tickets platform
-- Only insert if the currency doesn't already exist to avoid duplicates

INSERT INTO public.currencies (code, name, symbol, decimal_places, is_active) 
SELECT * FROM (
    VALUES 
        ('COP', 'Colombian Peso', '$', 0, true),
        ('USD', 'US Dollar', '$', 2, true)
) AS new_currencies(code, name, symbol, decimal_places, is_active)
WHERE NOT EXISTS (
    SELECT 1 FROM public.currencies WHERE code = new_currencies.code
);