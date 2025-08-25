-- Drop roles and test tables
-- These tables are no longer needed in the application

-- Drop test table with all its constraints, indexes, and policies
DROP TABLE IF EXISTS public.test CASCADE;

-- Drop roles table with all its constraints, indexes, and policies  
DROP TABLE IF EXISTS public.roles CASCADE;