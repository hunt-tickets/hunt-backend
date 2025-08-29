-- Add unique url column to producers table
ALTER TABLE producers 
ADD COLUMN url TEXT UNIQUE;