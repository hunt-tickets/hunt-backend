-- Allow universal INSERT access to refunds table
-- Created 2025-08-26

-- Drop existing INSERT policies
DROP POLICY IF EXISTS "Authenticated users can create refunds" ON refunds;
DROP POLICY IF EXISTS "Anonymous users can create refunds" ON refunds;
DROP POLICY IF EXISTS "Service role can create refunds" ON refunds;

-- Create universal INSERT policy
CREATE POLICY "Anyone can create refunds" ON refunds 
    FOR INSERT WITH CHECK (true);