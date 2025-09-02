-- Add event_id foreign key column to automatic_discounts table
ALTER TABLE automatic_discounts ADD COLUMN event_id UUID NOT NULL;

-- Add foreign key constraint to events table
ALTER TABLE automatic_discounts 
ADD CONSTRAINT automatic_discounts_event_id_fkey 
FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;

-- Create index on event_id for efficient queries
CREATE INDEX idx_automatic_discounts_event_id ON automatic_discounts(event_id);