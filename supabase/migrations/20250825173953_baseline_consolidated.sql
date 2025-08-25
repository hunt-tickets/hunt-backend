-- Consolidated baseline migration containing all schema from previous migrations
-- Created 2025-08-25 to resolve migration sync issues

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
DO $$ BEGIN
    CREATE TYPE event_status AS ENUM ('draft', 'published', 'cancelled', 'completed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE event_language AS ENUM ('en', 'es', 'fr', 'pt', 'it', 'de');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE discount_type AS ENUM ('percentage', 'fixed_amount', 'free');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE payment_status AS ENUM ('pending', 'processing', 'succeeded', 'failed', 'cancelled', 'refunded');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE adjustment_type AS ENUM ('refund', 'discount', 'fee', 'tax', 'chargeback');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create currencies table
CREATE TABLE IF NOT EXISTS currencies (
    id SERIAL PRIMARY KEY,
    code VARCHAR(3) NOT NULL UNIQUE,
    name JSONB NOT NULL,
    symbol VARCHAR(10) NOT NULL,
    decimal_places INTEGER DEFAULT 2,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert currency data
INSERT INTO currencies (code, name, symbol) VALUES
('USD', '{"en": "US Dollar", "es": "D�lar Estadounidense"}', '$'),
('EUR', '{"en": "Euro", "es": "Euro"}', '�'),
('GBP', '{"en": "British Pound", "es": "Libra Esterlina"}', '�'),
('CAD', '{"en": "Canadian Dollar", "es": "D�lar Canadiense"}', 'C$'),
('AUD', '{"en": "Australian Dollar", "es": "D�lar Australiano"}', 'A$'),
('JPY', '{"en": "Japanese Yen", "es": "Yen Japon�s"}', '�'),
('CHF', '{"en": "Swiss Franc", "es": "Franco Suizo"}', 'CHF'),
('CNY', '{"en": "Chinese Yuan", "es": "Yuan Chino"}', '�'),
('MXN', '{"en": "Mexican Peso", "es": "Peso Mexicano"}', '$'),
('BRL', '{"en": "Brazilian Real", "es": "Real Brasile�o"}', 'R$')
ON CONFLICT (code) DO NOTHING;

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    company VARCHAR(255),
    website VARCHAR(255),
    bio TEXT,
    avatar_url TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create countries table
CREATE TABLE IF NOT EXISTS countries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(3) NOT NULL UNIQUE,
    currency_code VARCHAR(3) NOT NULL,
    phone_prefix VARCHAR(10),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create producers table
CREATE TABLE IF NOT EXISTS producers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    website VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20),
    logo_url TEXT,
    banner_url TEXT,
    social_links JSONB DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create events table
CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    producer_id UUID REFERENCES producers(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    slug VARCHAR(255) UNIQUE NOT NULL,
    category JSONB NOT NULL DEFAULT '{}',
    event_type JSONB NOT NULL DEFAULT '{}',
    status event_status DEFAULT 'draft',
    language event_language DEFAULT 'en',
    
    -- Date and time
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE,
    timezone VARCHAR(50) DEFAULT 'UTC',
    
    -- Location
    venue_name VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Capacity and pricing
    capacity INTEGER,
    remaining_capacity INTEGER,
    min_price DECIMAL(10, 2),
    max_price DECIMAL(10, 2),
    currency_code VARCHAR(3) DEFAULT 'USD',
    is_free BOOLEAN DEFAULT FALSE,
    
    -- Features
    is_private BOOLEAN DEFAULT FALSE,
    requires_approval BOOLEAN DEFAULT FALSE,
    allow_waitlist BOOLEAN DEFAULT FALSE,
    
    -- Visual
    cover_image_url TEXT,
    gallery_urls TEXT[],
    primary_color VARCHAR(7),
    theme_mode VARCHAR(10) DEFAULT 'light',
    
    -- Ticket management
    ticket_sales_start TIMESTAMP WITH TIME ZONE,
    ticket_sales_end TIMESTAMP WITH TIME ZONE,
    max_tickets_per_order INTEGER DEFAULT 10,
    min_tickets_per_order INTEGER DEFAULT 1,
    
    -- Financial
    tax_rate DECIMAL(5, 4) DEFAULT 0,
    
    -- Calendar integration
    calendar_description TEXT,
    
    -- Confirmation settings
    confirmation_message TEXT,
    confirmation_redirect_url TEXT,
    send_confirmation_email BOOLEAN DEFAULT TRUE,
    
    -- Access control
    access_code VARCHAR(255),
    
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create events accessibility table
CREATE TABLE IF NOT EXISTS events_accessibility (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    wheelchair_accessible BOOLEAN DEFAULT FALSE,
    hearing_assistance BOOLEAN DEFAULT FALSE,
    visual_assistance BOOLEAN DEFAULT FALSE,
    parking_available BOOLEAN DEFAULT FALSE,
    public_transport_accessible BOOLEAN DEFAULT FALSE,
    restroom_accessible BOOLEAN DEFAULT FALSE,
    service_animals_welcome BOOLEAN DEFAULT FALSE,
    dietary_accommodations BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create events payment settings table
CREATE TABLE IF NOT EXISTS events_payment_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    stripe_account_id VARCHAR(255),
    processing_fee_percentage DECIMAL(5, 4) DEFAULT 0.029,
    processing_fee_fixed DECIMAL(10, 2) DEFAULT 0.30,
    platform_fee_percentage DECIMAL(5, 4) DEFAULT 0,
    platform_fee_fixed DECIMAL(10, 2) DEFAULT 0,
    payout_method VARCHAR(50) DEFAULT 'stripe',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create discount codes table
CREATE TABLE IF NOT EXISTS discount_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255),
    description TEXT,
    type discount_type NOT NULL,
    value DECIMAL(10, 2) NOT NULL,
    max_uses INTEGER,
    uses_count INTEGER DEFAULT 0,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create automatic discounts table
CREATE TABLE IF NOT EXISTS automatic_discounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type discount_type NOT NULL,
    value DECIMAL(10, 2) NOT NULL,
    min_quantity INTEGER DEFAULT 1,
    min_amount DECIMAL(10, 2),
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create events waitlist table
CREATE TABLE IF NOT EXISTS events_waitlist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    quantity_requested INTEGER DEFAULT 1,
    notified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(event_id, email)
);

-- Create events payments table
CREATE TABLE IF NOT EXISTS events_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    stripe_payment_intent_id VARCHAR(255),
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    status payment_status DEFAULT 'pending',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create events adjustments table
CREATE TABLE IF NOT EXISTS events_adjustments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID REFERENCES events_payments(id) ON DELETE CASCADE,
    type adjustment_type NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create events affiliates table
CREATE TABLE IF NOT EXISTS events_affiliates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    affiliate_code VARCHAR(50) NOT NULL,
    commission_percentage DECIMAL(5, 4) DEFAULT 0,
    commission_fixed DECIMAL(10, 2) DEFAULT 0,
    total_sales DECIMAL(10, 2) DEFAULT 0,
    total_commission DECIMAL(10, 2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(event_id, affiliate_code)
);

-- Create question types table
CREATE TABLE IF NOT EXISTS question_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    has_options BOOLEAN DEFAULT FALSE
);

-- Insert question types
INSERT INTO question_types (name, description, has_options) VALUES
('text', 'Single line text input', FALSE),
('textarea', 'Multi-line text input', FALSE),
('email', 'Email address input', FALSE),
('phone', 'Phone number input', FALSE),
('select', 'Single choice dropdown', TRUE),
('radio', 'Single choice radio buttons', TRUE),
('checkbox', 'Multiple choice checkboxes', TRUE),
('number', 'Numeric input', FALSE),
('date', 'Date picker', FALSE),
('url', 'Website URL input', FALSE)
ON CONFLICT (name) DO NOTHING;

-- Create checkout questions table
CREATE TABLE IF NOT EXISTS checkout_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    question_type_id INTEGER REFERENCES question_types(id),
    question_text TEXT NOT NULL,
    is_required BOOLEAN DEFAULT FALSE,
    applies_to VARCHAR(20) DEFAULT 'all',
    options TEXT[],
    placeholder_text VARCHAR(255),
    validation_rules JSONB DEFAULT '{}',
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES 
('events', 'events', TRUE, 52428800, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'])
ON CONFLICT (id) DO NOTHING;

-- Create performance indexes
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_producers_user_id ON producers(user_id);
CREATE INDEX IF NOT EXISTS idx_events_producer_id ON events(producer_id);
CREATE INDEX IF NOT EXISTS idx_events_start_date ON events(start_date);
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);
CREATE INDEX IF NOT EXISTS idx_events_slug ON events(slug);
CREATE INDEX IF NOT EXISTS idx_events_accessibility_event_id ON events_accessibility(event_id);
CREATE INDEX IF NOT EXISTS idx_events_payment_settings_event_id ON events_payment_settings(event_id);
CREATE INDEX IF NOT EXISTS idx_discount_codes_event_id ON discount_codes(event_id);
CREATE INDEX IF NOT EXISTS idx_automatic_discounts_event_id ON automatic_discounts(event_id);
CREATE INDEX IF NOT EXISTS idx_events_waitlist_event_id ON events_waitlist(event_id);
CREATE INDEX IF NOT EXISTS idx_events_payments_event_id ON events_payments(event_id);
CREATE INDEX IF NOT EXISTS idx_events_payments_user_id ON events_payments(user_id);
CREATE INDEX IF NOT EXISTS idx_events_adjustments_payment_id ON events_adjustments(payment_id);
CREATE INDEX IF NOT EXISTS idx_events_affiliates_event_id ON events_affiliates(event_id);
CREATE INDEX IF NOT EXISTS idx_checkout_questions_event_id ON checkout_questions(event_id);

-- Add validation constraints
ALTER TABLE events 
ADD CONSTRAINT check_capacity_positive CHECK (capacity IS NULL OR capacity > 0),
ADD CONSTRAINT check_remaining_capacity_valid CHECK (remaining_capacity IS NULL OR remaining_capacity >= 0),
ADD CONSTRAINT check_price_positive CHECK ((min_price IS NULL OR min_price >= 0) AND (max_price IS NULL OR max_price >= 0)),
ADD CONSTRAINT check_price_order CHECK (min_price IS NULL OR max_price IS NULL OR min_price <= max_price),
ADD CONSTRAINT check_tax_rate_valid CHECK (tax_rate >= 0 AND tax_rate <= 1),
ADD CONSTRAINT check_ticket_order_limits CHECK (min_tickets_per_order > 0 AND max_tickets_per_order >= min_tickets_per_order);

ALTER TABLE discount_codes 
ADD CONSTRAINT check_discount_value_positive CHECK (value >= 0),
ADD CONSTRAINT check_max_uses_positive CHECK (max_uses IS NULL OR max_uses > 0),
ADD CONSTRAINT check_uses_count_valid CHECK (uses_count >= 0);

ALTER TABLE automatic_discounts 
ADD CONSTRAINT check_automatic_discount_value_positive CHECK (value >= 0),
ADD CONSTRAINT check_min_quantity_positive CHECK (min_quantity > 0),
ADD CONSTRAINT check_min_amount_positive CHECK (min_amount IS NULL OR min_amount >= 0);

ALTER TABLE events_payments 
ADD CONSTRAINT check_payment_amount_positive CHECK (amount > 0);

ALTER TABLE events_adjustments 
ADD CONSTRAINT check_adjustment_amount_not_zero CHECK (amount != 0);

-- Enable RLS on all tables
ALTER TABLE currencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE countries ENABLE ROW LEVEL SECURITY;
ALTER TABLE producers ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE events_accessibility ENABLE ROW LEVEL SECURITY;
ALTER TABLE events_payment_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE discount_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE automatic_discounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE events_waitlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE events_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE events_adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE events_affiliates ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkout_questions ENABLE ROW LEVEL SECURITY;

-- Create basic RLS policies for public read access
CREATE POLICY "Public read access for currencies" ON currencies FOR SELECT USING (true);
CREATE POLICY "Public read access for countries" ON countries FOR SELECT USING (true);  
CREATE POLICY "Public read access for question_types" ON question_types FOR SELECT USING (true);

-- Create storage policies
CREATE POLICY "Public read access for events bucket" ON storage.objects FOR SELECT USING (bucket_id = 'events');
CREATE POLICY "Authenticated users can upload to events bucket" ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'events' AND auth.role() = 'authenticated'
);
CREATE POLICY "Users can update their own uploads in events bucket" ON storage.objects FOR UPDATE USING (
    bucket_id = 'events' AND auth.uid()::text = (storage.foldername(name))[1]
) WITH CHECK (
    bucket_id = 'events' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "Users can delete their own uploads in events bucket" ON storage.objects FOR DELETE USING (
    bucket_id = 'events' AND auth.uid()::text = (storage.foldername(name))[1]
);