-- Add primary_color and theme_mode columns to events table
-- For customizing event appearance and theming
-- Also create discount_codes table

-- Create theme_mode enum type
CREATE TYPE theme_mode_type AS ENUM ('light', 'dark', 'adaptive');

-- Add primary_color column (hex color code)
ALTER TABLE public.events ADD COLUMN primary_color TEXT DEFAULT '#007bff';

-- Add theme_mode column with enum
ALTER TABLE public.events ADD COLUMN theme_mode theme_mode_type DEFAULT 'adaptive';

-- Add constraint to validate hex color format
ALTER TABLE public.events ADD CONSTRAINT events_primary_color_hex_format 
CHECK (primary_color ~* '^#[0-9a-f]{6}$');

-- Add index for theme_mode for efficient filtering
CREATE INDEX idx_events_theme_mode ON public.events(theme_mode);

-- Add index for primary_color in case we want to filter by color
CREATE INDEX idx_events_primary_color ON public.events(primary_color);

-- Create discount_code_type enum
CREATE TYPE discount_code_type AS ENUM ('percentage', 'fixed_amount');

-- Create discount_codes table
CREATE TABLE public.discount_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
    code TEXT NOT NULL UNIQUE,
    discount_code_type discount_code_type NOT NULL,
    amount NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    quantity NUMERIC NOT NULL DEFAULT 1 CHECK (quantity >= 0),
    max_usage NUMERIC NOT NULL DEFAULT 1 CHECK (max_usage > 0),
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    status BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for discount_codes table
CREATE INDEX idx_discount_codes_event_id ON public.discount_codes(event_id);
CREATE INDEX idx_discount_codes_code ON public.discount_codes(code);
CREATE INDEX idx_discount_codes_status ON public.discount_codes(status);
CREATE INDEX idx_discount_codes_start_time ON public.discount_codes(start_time);
CREATE INDEX idx_discount_codes_end_time ON public.discount_codes(end_time);
CREATE INDEX idx_discount_codes_type ON public.discount_codes(discount_code_type);

-- Enable RLS on discount_codes
ALTER TABLE public.discount_codes ENABLE ROW LEVEL SECURITY;

-- Policies for discount_codes
CREATE POLICY "Authenticated users can view discount codes" 
ON public.discount_codes 
FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "Service role can manage discount codes" 
ON public.discount_codes 
FOR ALL 
TO service_role 
USING (true);

-- Create trigger for updated_at on discount_codes
CREATE TRIGGER update_discount_codes_updated_at 
    BEFORE UPDATE ON public.discount_codes 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Add constraints for discount_codes
ALTER TABLE public.discount_codes ADD CONSTRAINT discount_codes_end_time_after_start 
CHECK (end_time > start_time);

ALTER TABLE public.discount_codes ADD CONSTRAINT discount_codes_code_format 
CHECK (char_length(code) >= 3 AND char_length(code) <= 50);