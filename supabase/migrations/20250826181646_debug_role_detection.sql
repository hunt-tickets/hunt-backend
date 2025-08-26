-- Debug role detection for refunds table
-- Created 2025-08-26

-- Create debug function to log current role
CREATE OR REPLACE FUNCTION debug_current_role() 
RETURNS TEXT AS $$
BEGIN
    -- Log different role detection methods
    RAISE WARNING 'current_user: %, session_user: %, current_role: %', 
        current_user, session_user, current_role;
    
    -- Return current role for debugging
    RETURN current_role;
END;
$$ LANGUAGE plpgsql;

-- Drop existing anon policy
DROP POLICY IF EXISTS "Anon can insert refunds" ON refunds;

-- Create temporary debug policy that allows any role but logs what it detects
CREATE POLICY "Debug - Allow all inserts with logging" ON refunds 
FOR INSERT 
WITH CHECK (debug_current_role() IS NOT NULL);

-- Also create specific policies to test different role detection
CREATE POLICY "Test anon role" ON refunds 
FOR INSERT TO anon 
WITH CHECK (true);

CREATE POLICY "Test authenticated role" ON refunds 
FOR INSERT TO authenticated 
WITH CHECK (true);

CREATE POLICY "Test public role" ON refunds 
FOR INSERT TO public 
WITH CHECK (true);