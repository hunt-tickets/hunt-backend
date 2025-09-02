-- Fix refunds RLS policy for public insert compatibility with publishable keys
-- Created 2025-08-26

-- Drop existing anonymous insert policy
DROP POLICY IF EXISTS "Anonymous can create refunds" ON refunds;

-- Create new policy that works with both anon and publishable keys
CREATE POLICY "Public can create refunds" ON refunds 
    FOR INSERT 
    WITH CHECK (auth.role() IS NULL OR auth.role() = 'anon');