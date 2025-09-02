-- Temporarily disable RLS to test if the issue is authentication vs authorization
-- Created 2025-08-26

-- Disable RLS on refunds table temporarily
ALTER TABLE refunds DISABLE ROW LEVEL SECURITY;