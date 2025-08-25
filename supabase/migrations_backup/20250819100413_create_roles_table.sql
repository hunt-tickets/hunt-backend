-- Create roles table for Hunt Tickets platform
CREATE TABLE public.roles (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    description TEXT,
    permissions JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX idx_roles_name ON public.roles(name);
CREATE INDEX idx_roles_active ON public.roles(is_active);

-- Enable RLS (Row Level Security)
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

-- Policy for reading roles (authenticated users only)
CREATE POLICY "Authenticated users can view roles" 
ON public.roles 
FOR SELECT 
TO authenticated 
USING (true);

-- Policy for managing roles (simplified - no user_roles dependency)
CREATE POLICY "Service role can manage roles" 
ON public.roles 
FOR ALL 
TO service_role 
USING (true);

-- Allow authenticated users to manage roles (can be restricted later)
CREATE POLICY "Authenticated users can manage roles" 
ON public.roles 
FOR ALL 
TO authenticated 
USING (true);

-- Create trigger for updated_at
CREATE TRIGGER update_roles_updated_at 
    BEFORE UPDATE ON public.roles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();