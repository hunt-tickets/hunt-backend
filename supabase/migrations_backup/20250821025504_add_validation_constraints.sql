-- Add validation constraints for data integrity

-- Events: event_date should be before or equal to end_date
ALTER TABLE events ADD CONSTRAINT check_event_dates 
CHECK (event_date <= end_date OR end_date IS NULL);

-- Events: min_tickets should be less than or equal to max_tickets
ALTER TABLE events ADD CONSTRAINT check_ticket_limits
CHECK (min_tickets <= max_tickets OR min_tickets IS NULL OR max_tickets IS NULL);

-- Events: checkout_time should be positive
ALTER TABLE events ADD CONSTRAINT check_checkout_time_positive
CHECK (checkout_time > 0 OR checkout_time IS NULL);

-- Events Payments: amount should be positive
ALTER TABLE events_payments ADD CONSTRAINT check_positive_amount 
CHECK (amount > 0);

-- Events Adjustments: amount should not be zero
ALTER TABLE events_adjustments ADD CONSTRAINT check_adjustment_amount_not_zero
CHECK (amount != 0);

-- Automatic Discounts: start_at should be before end_at
ALTER TABLE automatic_discounts ADD CONSTRAINT check_discount_dates 
CHECK (start_at < end_at);

-- Automatic Discounts: amount should be positive
ALTER TABLE automatic_discounts ADD CONSTRAINT check_discount_amount_positive
CHECK (amount > 0);

-- Automatic Discounts: quantity and max_usage should be positive
ALTER TABLE automatic_discounts ADD CONSTRAINT check_discount_quantities_positive
CHECK (quantity > 0 AND max_usage > 0);

-- Discount Codes: amount should be positive
ALTER TABLE discount_codes ADD CONSTRAINT check_discount_code_amount_positive
CHECK (amount > 0);

-- Discount Codes: start_time should be before end_time
ALTER TABLE discount_codes ADD CONSTRAINT check_discount_code_dates
CHECK (start_time < end_time);

-- Discount Codes: quantity and max_usage should be positive
ALTER TABLE discount_codes ADD CONSTRAINT check_discount_code_quantities_positive
CHECK (quantity > 0 AND max_usage > 0);

-- Events Payment Settings: amounts should be non-negative
ALTER TABLE events_payment_settings ADD CONSTRAINT check_refundable_amount_non_negative
CHECK (refundable_amount >= 0 OR refundable_amount IS NULL);

ALTER TABLE events_payment_settings ADD CONSTRAINT check_variable_fee_non_negative
CHECK (variable_fee >= 0 OR variable_fee IS NULL);

ALTER TABLE events_payment_settings ADD CONSTRAINT check_fixed_fee_non_negative
CHECK (fixed_fee >= 0 OR fixed_fee IS NULL);

-- Events Waitlist: max_capacity should be positive
ALTER TABLE events_waitlist ADD CONSTRAINT check_waitlist_max_capacity_positive
CHECK (max_capacity > 0 OR max_capacity IS NULL);

-- Events Access Code: quantity should be positive
ALTER TABLE events_access_code ADD CONSTRAINT check_access_code_quantity_positive
CHECK (quantity > 0);

-- Events Checkout Questions: order_index should be non-negative
ALTER TABLE events_checkout_questions ADD CONSTRAINT check_order_index_non_negative
CHECK (order_index >= 0);