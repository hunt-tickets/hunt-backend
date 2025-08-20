-- Add tax boolean column to events table
ALTER TABLE events ADD COLUMN tax BOOLEAN DEFAULT false;