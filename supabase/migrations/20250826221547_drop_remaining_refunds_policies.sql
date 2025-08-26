-- Drop all remaining RLS policies from refunds table as shown in dashboard
-- Created 2025-08-26

-- Drop specific policies visible in the Supabase dashboard
DROP POLICY IF EXISTS "Debug - Allow all inserts with logging" ON refunds;
DROP POLICY IF EXISTS "Test anon role" ON refunds;
DROP POLICY IF EXISTS "Test authenticated role" ON refunds;
DROP POLICY IF EXISTS "Test public role" ON refunds;

-- Additional cleanup of any other possible policy names
DROP POLICY IF EXISTS "Debug-Allow all inserts with logging" ON refunds;
DROP POLICY IF EXISTS "Debug_Allow_all_inserts_with_logging" ON refunds;