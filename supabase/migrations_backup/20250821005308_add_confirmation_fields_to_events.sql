-- Add confirmation_email and confirmation_page columns to events table
-- For storing confirmation email template and confirmation page content

-- Add confirmation_email column
ALTER TABLE public.events ADD COLUMN confirmation_email TEXT;

-- Add confirmation_page column
ALTER TABLE public.events ADD COLUMN confirmation_page TEXT;

-- Add constraints for confirmation fields (reasonable length limits)
ALTER TABLE public.events ADD CONSTRAINT events_confirmation_email_length 
CHECK (confirmation_email IS NULL OR char_length(confirmation_email) <= 5000);

ALTER TABLE public.events ADD CONSTRAINT events_confirmation_page_length 
CHECK (confirmation_page IS NULL OR char_length(confirmation_page) <= 10000);

-- Add helpful comments
COMMENT ON COLUMN public.events.confirmation_email IS 
'Email template content for ticket confirmation emails. HTML/text content up to 5000 characters.';

COMMENT ON COLUMN public.events.confirmation_page IS 
'Confirmation page content displayed after successful ticket purchase. HTML/text content up to 10000 characters.';