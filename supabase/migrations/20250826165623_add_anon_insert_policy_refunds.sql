-- Allow anonymous users to insert refunds
-- Created 2025-08-26

-- Policy to allow anonymous users to create refunds
CREATE POLICY "Anonymous users can create refunds" ON refunds 
    FOR INSERT WITH CHECK (auth.role() = 'anon');