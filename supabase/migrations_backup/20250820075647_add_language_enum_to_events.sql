-- Create language enum type
CREATE TYPE language_type AS ENUM ('es', 'en', 'pt', 'fr');

-- Add language column to events table
ALTER TABLE events ADD COLUMN language language_type DEFAULT 'es';

-- Create index on language for efficient filtering
CREATE INDEX idx_events_language ON events(language);