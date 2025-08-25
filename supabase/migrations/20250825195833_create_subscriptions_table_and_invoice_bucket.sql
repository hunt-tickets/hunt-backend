-- Create subscriptions table and invoice storage bucket
-- Created 2025-08-25

-- Create subscriptions table
CREATE TABLE subscriptions (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    company TEXT NOT NULL,
    service TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    currency TEXT NOT NULL,
    payment_method TEXT NOT NULL,
    receipt_name TEXT NOT NULL,
    date TIMESTAMPTZ NOT NULL,
    metadata JSONB DEFAULT '{}',
    
    -- Primary key
    CONSTRAINT subscriptions_pkey PRIMARY KEY (id),
    
    -- Unique constraint on combination of fields
    CONSTRAINT unique_subscription_combination UNIQUE (
        company, 
        amount, 
        currency, 
        payment_method, 
        receipt_name, 
        date
    )
);

-- Create invoice storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) 
VALUES (
    'invoice', 
    'invoice', 
    FALSE,  -- Private bucket for invoices
    10485760,  -- 10MB limit
    ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/webp']
);

-- Enable RLS on subscriptions table
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for subscriptions table
CREATE POLICY "Authenticated users can view their own subscriptions" ON subscriptions 
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can create subscriptions" ON subscriptions 
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update their own subscriptions" ON subscriptions 
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Create storage policies for invoice bucket
CREATE POLICY "Authenticated users can view invoice files" ON storage.objects 
    FOR SELECT USING (bucket_id = 'invoice' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can upload to subscriptions folder" ON storage.objects 
    FOR INSERT WITH CHECK (
        bucket_id = 'invoice' 
        AND auth.role() = 'authenticated'
        AND (storage.foldername(name))[1] = 'subscriptions'
    );

CREATE POLICY "Users can update their own invoice files" ON storage.objects 
    FOR UPDATE USING (
        bucket_id = 'invoice' 
        AND auth.role() = 'authenticated'
    ) WITH CHECK (
        bucket_id = 'invoice' 
        AND auth.role() = 'authenticated'
    );

CREATE POLICY "Users can delete their own invoice files" ON storage.objects 
    FOR DELETE USING (
        bucket_id = 'invoice' 
        AND auth.role() = 'authenticated'
    );

-- Create performance indexes
CREATE INDEX idx_subscriptions_company ON subscriptions(company);
CREATE INDEX idx_subscriptions_date ON subscriptions(date);
CREATE INDEX idx_subscriptions_created_at ON subscriptions(created_at);