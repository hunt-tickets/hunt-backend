-- Allow unrestricted public insert access to refunds table
-- Created 2025-08-26

-- Drop existing policy
DROP POLICY IF EXISTS "Public can create refunds" ON refunds;

-- Create policy that allows anyone to insert refunds (truly public)
CREATE POLICY "Anyone can create refunds" ON refunds 
    FOR INSERT 
    TO public
    WITH CHECK (true);