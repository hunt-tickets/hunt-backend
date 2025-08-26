-- Fix refunds RLS policy with correct TO clause syntax for publishable key compatibility
-- Created 2025-08-26

-- Drop existing policy with incorrect syntax
DROP POLICY IF EXISTS "Public can create refunds" ON refunds;

-- Create policy with correct TO clause syntax for publishable keys
CREATE POLICY "Public can create refunds" ON refunds 
    FOR INSERT 
    TO anon, authenticated
    WITH CHECK (true);