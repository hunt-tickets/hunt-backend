-- Clean up refunds RLS policies and keep only anon insert
-- Created 2025-08-26

-- Drop all existing policies
DROP POLICY IF EXISTS "Anon can insert refunds" ON refunds;
DROP POLICY IF EXISTS "Authenticated can insert refunds" ON refunds;
DROP POLICY IF EXISTS "Authenticated can select refunds" ON refunds;
DROP POLICY IF EXISTS "Authenticated can update refunds" ON refunds;
DROP POLICY IF EXISTS "Service role can select refunds" ON refunds;
DROP POLICY IF EXISTS "Service role can insert refunds" ON refunds;
DROP POLICY IF EXISTS "Service role can update refunds" ON refunds;
DROP POLICY IF EXISTS "Service role can delete refunds" ON refunds;

-- Create only anon insert policy
CREATE POLICY "Anon can insert refunds" ON refunds 
FOR INSERT TO anon;