-- Add metadata JSONB column to producers table
ALTER TABLE producers ADD COLUMN metadata JSONB DEFAULT NULL;