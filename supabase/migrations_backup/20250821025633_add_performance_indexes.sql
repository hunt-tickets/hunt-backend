-- Add composite indexes for better query performance

-- Events: Common queries by status and date
CREATE INDEX idx_events_status_date ON events(status, event_date);
CREATE INDEX idx_events_status_language ON events(status, language);
CREATE INDEX idx_events_privacy_status ON events(privacy, status);

-- Discount Codes: Active codes by event
CREATE INDEX idx_discount_codes_event_active ON discount_codes(event_id, status);
CREATE INDEX idx_discount_codes_event_dates ON discount_codes(event_id, start_time, end_time);

-- Automatic Discounts: Active discounts by event
CREATE INDEX idx_automatic_discounts_event_active ON automatic_discounts(event_id, status);
CREATE INDEX idx_automatic_discounts_event_dates ON automatic_discounts(event_id, start_at, end_at);

-- Events Payments: Payments by event and date
CREATE INDEX idx_events_payments_event_date ON events_payments(event_id, payment_date);
CREATE INDEX idx_events_payments_currency_date ON events_payments(currency_id, payment_date);

-- Events Adjustments: Adjustments by event and type
CREATE INDEX idx_events_adjustments_event_type ON events_adjustments(event_id, adjustment_type);
CREATE INDEX idx_events_adjustments_event_date ON events_adjustments(event_id, date);

-- Events Payment Settings: Quick lookup by event
CREATE INDEX idx_events_payment_settings_event ON events_payment_settings(event_id);

-- Events Waitlist: Active waitlists by event
CREATE INDEX idx_events_waitlist_event_status ON events_waitlist(event_id, status);

-- Events Affiliates: Active affiliates by event
CREATE INDEX idx_events_affiliates_event_status ON events_affiliates(event_id, status);

-- Events Access Code: Active codes by event
CREATE INDEX idx_events_access_code_event_status ON events_access_code(event_id, status);

-- Events Checkout Questions: Questions by event and order
CREATE INDEX idx_events_checkout_questions_event_order_active ON events_checkout_questions(event_id, order_index, is_active);

-- Profiles: Common lookups
CREATE INDEX idx_profiles_email_active ON profiles(email) WHERE email IS NOT NULL;

-- Question Types: Active types lookup
CREATE INDEX idx_question_types_active_name ON question_types(is_active, name);