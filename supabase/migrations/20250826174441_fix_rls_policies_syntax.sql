-- Fix RLS policies syntax for refunds table
-- Created 2025-08-26

-- Drop all existing policies
DROP POLICY IF EXISTS "Anyone can create refunds" ON refunds;
DROP POLICY IF EXISTS "Authenticated users can view their own refunds" ON refunds;
DROP POLICY IF EXISTS "Authenticated users can update their own refunds" ON refunds;
DROP POLICY IF EXISTS "Service role can view all refunds" ON refunds;
DROP POLICY IF EXISTS "Service role can update all refunds" ON refunds;
DROP POLICY IF EXISTS "Service role can delete refunds" ON refunds;

-- Create policies with correct syntax
CREATE POLICY "Anon can insert refunds" ON refunds 
FOR INSERT TO anon;

CREATE POLICY "Authenticated can insert refunds" ON refunds 
FOR INSERT TO authenticated;

CREATE POLICY "Authenticated can select refunds" ON refunds 
FOR SELECT TO authenticated;

CREATE POLICY "Authenticated can update refunds" ON refunds 
FOR UPDATE TO authenticated;

CREATE POLICY "Service role can select refunds" ON refunds 
FOR SELECT TO service_role;

CREATE POLICY "Service role can insert refunds" ON refunds 
FOR INSERT TO service_role;

CREATE POLICY "Service role can update refunds" ON refunds 
FOR UPDATE TO service_role;

CREATE POLICY "Service role can delete refunds" ON refunds 
FOR DELETE TO service_role;