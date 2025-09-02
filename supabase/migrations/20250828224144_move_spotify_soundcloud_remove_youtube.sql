-- Move Spotify and SoundCloud columns from producers to producers_social_media
-- and remove YouTube column from producers_social_media

-- Step 1: Add Spotify and SoundCloud columns to producers_social_media
ALTER TABLE producers_social_media 
ADD COLUMN spotify TEXT,
ADD COLUMN soundcloud TEXT;

-- Step 2: Copy existing data from producers to producers_social_media
-- First, ensure all producers have a social media record
INSERT INTO producers_social_media (producer_id)
SELECT p.id 
FROM producers p
LEFT JOIN producers_social_media psm ON p.id = psm.producer_id
WHERE psm.producer_id IS NULL;

-- Copy the data
UPDATE producers_social_media 
SET 
  spotify = p.spotify,
  soundcloud = p.soundcloud
FROM producers p
WHERE producers_social_media.producer_id = p.id;

-- Step 3: Drop the columns from producers table
ALTER TABLE producers 
DROP COLUMN spotify,
DROP COLUMN soundcloud;

-- Step 4: Remove YouTube column from producers_social_media
ALTER TABLE producers_social_media 
DROP COLUMN youtube;