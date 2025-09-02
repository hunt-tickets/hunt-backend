-- Improve default values for better user experience and consistency

-- Events: Set better defaults
ALTER TABLE events ALTER COLUMN timezone SET DEFAULT 'America/Bogota';
ALTER TABLE events ALTER COLUMN language SET DEFAULT 'es';
ALTER TABLE events ALTER COLUMN privacy SET DEFAULT 'public';
ALTER TABLE events ALTER COLUMN status SET DEFAULT 'draft';
ALTER TABLE events ALTER COLUMN theme_mode SET DEFAULT 'light';
ALTER TABLE events ALTER COLUMN frequency SET DEFAULT 'single';

-- Events Payment Settings: Set sensible defaults
ALTER TABLE events_payment_settings ALTER COLUMN tax SET DEFAULT false;
ALTER TABLE events_payment_settings ALTER COLUMN self_refund SET DEFAULT false;
ALTER TABLE events_payment_settings ALTER COLUMN refundable_amount SET DEFAULT 0;
ALTER TABLE events_payment_settings ALTER COLUMN variable_fee SET DEFAULT 0;
ALTER TABLE events_payment_settings ALTER COLUMN fixed_fee SET DEFAULT 0;
ALTER TABLE events_payment_settings ALTER COLUMN fee_payment SET DEFAULT 'absorver_fees';

-- Events Waitlist: Set defaults
ALTER TABLE events_waitlist ALTER COLUMN status SET DEFAULT false;
ALTER TABLE events_waitlist ALTER COLUMN total_capacity SET DEFAULT false;
ALTER TABLE events_waitlist ALTER COLUMN tickets_sold_out SET DEFAULT false;
ALTER TABLE events_waitlist ALTER COLUMN ticket_trigger SET DEFAULT 'automatic';

-- Automatic Discounts: Set defaults
ALTER TABLE automatic_discounts ALTER COLUMN quantity SET DEFAULT 1;
ALTER TABLE automatic_discounts ALTER COLUMN max_usage SET DEFAULT 1;
ALTER TABLE automatic_discounts ALTER COLUMN status SET DEFAULT true;

-- Discount Codes: Set defaults
ALTER TABLE discount_codes ALTER COLUMN quantity SET DEFAULT 1;
ALTER TABLE discount_codes ALTER COLUMN max_usage SET DEFAULT 1;
ALTER TABLE discount_codes ALTER COLUMN status SET DEFAULT true;

-- Events Affiliates: Ensure status default
ALTER TABLE events_affiliates ALTER COLUMN status SET DEFAULT true;

-- Events Access Code: Set defaults
ALTER TABLE events_access_code ALTER COLUMN quantity SET DEFAULT 1;
ALTER TABLE events_access_code ALTER COLUMN status SET DEFAULT true;

-- Events Checkout Questions: Set defaults
ALTER TABLE events_checkout_questions ALTER COLUMN order_index SET DEFAULT 0;
ALTER TABLE events_checkout_questions ALTER COLUMN is_required SET DEFAULT false;
ALTER TABLE events_checkout_questions ALTER COLUMN is_active SET DEFAULT true;

-- Question Types: Ensure active by default
ALTER TABLE question_types ALTER COLUMN is_active SET DEFAULT true;