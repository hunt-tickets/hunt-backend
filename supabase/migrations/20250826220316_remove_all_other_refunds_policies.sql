-- Remove all other RLS policies on refunds table, keep only public INSERT
-- Created 2025-08-26

-- Drop all existing policies except the current INSERT policy
DROP POLICY IF EXISTS "Authenticated can view all refunds" ON refunds;
DROP POLICY IF EXISTS "Authenticated can update refunds" ON refunds;
DROP POLICY IF EXISTS "Service role has full access to refunds" ON refunds;
DROP POLICY IF EXISTS "Authenticated users can view their own refunds" ON refunds;
DROP POLICY IF EXISTS "Authenticated users can create refunds" ON refunds;
DROP POLICY IF EXISTS "Authenticated users can update their own refunds" ON refunds;
DROP POLICY IF EXISTS "Anon can insert refunds" ON refunds;
DROP POLICY IF EXISTS "Authenticated can insert refunds" ON refunds;
DROP POLICY IF EXISTS "Authenticated can select refunds" ON refunds;
DROP POLICY IF EXISTS "Service role can select refunds" ON refunds;
DROP POLICY IF EXISTS "Service role can insert refunds" ON refunds;
DROP POLICY IF EXISTS "Service role can update refunds" ON refunds;
DROP POLICY IF EXISTS "Service role can delete refunds" ON refunds;

-- Keep only the public INSERT policy (already exists from previous migration)