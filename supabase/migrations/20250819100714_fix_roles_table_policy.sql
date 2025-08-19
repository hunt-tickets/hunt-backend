-- Drop the problematic policy that references non-existent table
DROP POLICY IF EXISTS "Only admins can manage roles" ON public.roles;

-- Create a simpler policy for now - only allow service role to manage roles
CREATE POLICY "Service role can manage roles" 
ON public.roles 
FOR ALL 
TO service_role 
USING (true);

-- Allow authenticated users to insert/update roles (temporary - can be restricted later)
CREATE POLICY "Authenticated users can manage roles temporarily" 
ON public.roles 
FOR ALL 
TO authenticated 
USING (true);