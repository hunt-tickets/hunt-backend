-- Add ticket management fields to events table
-- min_tickets, max_tickets, tickets_left, add_calendar, checkout_time

-- Add min_tickets column (minimum tickets per purchase)
ALTER TABLE public.events ADD COLUMN min_tickets INTEGER DEFAULT 1 CHECK (min_tickets > 0);

-- Add max_tickets column (maximum tickets per purchase)
ALTER TABLE public.events ADD COLUMN max_tickets INTEGER DEFAULT 10 CHECK (max_tickets > 0);

-- Add tickets_left column (boolean to show if tickets are available)
ALTER TABLE public.events ADD COLUMN tickets_left BOOLEAN DEFAULT true;

-- Add add_calendar column (boolean to allow adding to calendar)
ALTER TABLE public.events ADD COLUMN add_calendar BOOLEAN DEFAULT true;

-- Add checkout_time column (time limit for checkout in minutes)
ALTER TABLE public.events ADD COLUMN checkout_time NUMERIC DEFAULT 15 CHECK (checkout_time > 0);

-- Add constraint to ensure max_tickets >= min_tickets
ALTER TABLE public.events ADD CONSTRAINT events_max_tickets_gte_min_tickets 
CHECK (max_tickets >= min_tickets);

-- Add indexes for ticket management fields
CREATE INDEX idx_events_tickets_left ON public.events(tickets_left);
CREATE INDEX idx_events_min_tickets ON public.events(min_tickets);
CREATE INDEX idx_events_max_tickets ON public.events(max_tickets);