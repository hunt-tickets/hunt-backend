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

-- Create storage bucket for events if not exists
DO $$ BEGIN
    INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) 
    VALUES ('events', 'events', TRUE, 52428800, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']);
EXCEPTION
    WHEN unique_violation THEN null;
END $$;

-- Create performance indexes that might be missing
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_producers_user_id ON producers(user_id);
CREATE INDEX IF NOT EXISTS idx_events_producer_id ON events(producer_id);
CREATE INDEX IF NOT EXISTS idx_events_start_date ON events(start_date);
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);
CREATE INDEX IF NOT EXISTS idx_events_slug ON events(slug);

-- Migration complete - all tables already exist from previous deployments