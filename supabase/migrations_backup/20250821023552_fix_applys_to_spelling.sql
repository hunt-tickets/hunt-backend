-- Fix spelling: rename applys_to to applies_to in all tables

-- Fix discount_codes table
ALTER TABLE discount_codes RENAME COLUMN applys_to TO applies_to;

-- Fix automatic_discounts table  
ALTER TABLE automatic_discounts RENAME COLUMN applys_to TO applies_to;

-- Fix events_waitlist table
ALTER TABLE events_waitlist RENAME COLUMN applys_to TO applies_to;

-- Note: events_access_code and events_checkout_questions already have correct spelling (applies_to)