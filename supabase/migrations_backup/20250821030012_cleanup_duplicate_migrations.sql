-- Migration cleanup placeholder
-- This migration serves as a marker for the cleanup of duplicate migration files
-- The actual cleanup is done by removing the duplicate files from the filesystem

-- Duplicate migrations removed:
-- 20250820065519_add_event_id_to_automatic_discounts.sql (kept 20250820065450)
-- 20250820071123_add_tax_column_to_events.sql (kept 20250820065731)  
-- 20250820075105_create_events_payment_settings_table.sql (kept 20250820072338)
-- 20250820080850_add_language_enum_to_events.sql (kept 20250820075647)
-- 20250820175938_add_fee_columns_to_payment_settings.sql (kept 20250820081404)
-- 20250820182049_create_events_waitlist_table.sql (kept 20250820182100)
-- 20250820184516_add_metadata_to_producers.sql (kept 20250820182659)
-- 20250820195928_create_events_payments_table.sql (kept 20250820185157)
-- 20250820201908_create_events_adjustments_table.sql (kept 20250820201159)
-- 20250821012025_create_events_affiliates_table.sql (kept 20250821012729)
-- 20250821012817_create_events_access_code_and_add_status.sql (kept 20250821013405)

SELECT 'Migration cleanup completed' AS status;