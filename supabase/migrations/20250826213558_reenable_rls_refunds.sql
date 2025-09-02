-- Re-enable RLS on refunds table with comprehensive policies
-- Created 2025-08-26

-- Re-enable RLS on refunds table
ALTER TABLE refunds ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to start fresh
DROP POLICY IF EXISTS "Anon can insert refunds" ON refunds;

-- Create comprehensive RLS policies for refunds

-- Allow anonymous users to create refunds (public form submission)
CREATE POLICY "Anonymous can create refunds" ON refunds 
    FOR INSERT TO anon 
    WITH CHECK (true);

-- Allow authenticated users to view all refunds (admin access)
CREATE POLICY "Authenticated can view all refunds" ON refunds 
    FOR SELECT TO authenticated 
    USING (true);

-- Allow authenticated users to update refunds (admin operations)
CREATE POLICY "Authenticated can update refunds" ON refunds 
    FOR UPDATE TO authenticated 
    USING (true) 
    WITH CHECK (true);

-- Allow service role full access for backend operations
CREATE POLICY "Service role has full access to refunds" ON refunds 
    FOR ALL TO service_role 
    USING (true) 
    WITH CHECK (true);