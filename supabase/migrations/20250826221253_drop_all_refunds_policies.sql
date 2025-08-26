-- Drop all RLS policies from refunds table
-- Created 2025-08-26

-- Drop the public INSERT policy
DROP POLICY IF EXISTS "Anyone can create refunds" ON refunds;