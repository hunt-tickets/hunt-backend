-- Simple baseline migration - only structure, no data inserts
-- Created 2025-08-25 to resolve migration sync issues

-- This migration is intentionally minimal to avoid conflicts with existing data

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types with proper error handling
DO $$ BEGIN
    CREATE TYPE event_status AS ENUM ('draft', 'published', 'cancelled', 'completed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE event_language AS ENUM ('en', 'es', 'fr', 'pt', 'it', 'de');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE discount_type AS ENUM ('percentage', 'fixed_amount', 'free');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE payment_status AS ENUM ('pending', 'processing', 'succeeded', 'failed', 'cancelled', 'refunded');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE adjustment_type AS ENUM ('refund', 'discount', 'fee', 'tax', 'chargeback');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Migration complete - only ENUM types created/verified
-- All tables and data already exist from previous deployments