-- Drop unwanted catalog views created in previous migrations
-- User requested no views, only table columns

-- Drop event_types_catalog view if it exists
DROP VIEW IF EXISTS event_types_catalog;

-- Drop event_categories_catalog view if it exists  
DROP VIEW IF EXISTS event_categories_catalog;