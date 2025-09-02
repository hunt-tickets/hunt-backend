-- Create producers_social_media table and move social media columns from producers
CREATE TABLE public.producers_social_media (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  producer_id UUID NOT NULL,
  instagram TEXT,
  facebook TEXT,
  twitter TEXT,
  x TEXT,
  tiktok TEXT,
  youtube TEXT,
  linkedin TEXT,
  website TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (producer_id) REFERENCES producers(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE producers_social_media ENABLE ROW LEVEL SECURITY;

-- Remove social media columns from producers table
ALTER TABLE producers 
DROP COLUMN IF EXISTS instagram,
DROP COLUMN IF EXISTS facebook,
DROP COLUMN IF EXISTS twitter,
DROP COLUMN IF EXISTS x,
DROP COLUMN IF EXISTS tiktok,
DROP COLUMN IF EXISTS youtube,
DROP COLUMN IF EXISTS linkedin,
DROP COLUMN IF EXISTS website;