-- Add columns to test table for Hunt Tickets
ALTER TABLE public.test ADD COLUMN IF NOT EXISTS name TEXT;
ALTER TABLE public.test ADD COLUMN IF NOT EXISTS email TEXT UNIQUE;
ALTER TABLE public.test ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE public.test ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active';
ALTER TABLE public.test ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}';
ALTER TABLE public.test ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_test_updated_at 
    BEFORE UPDATE ON public.test 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();