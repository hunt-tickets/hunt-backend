-- Create refunds table and storage bucket
-- Created 2025-08-26

-- Create refund status enum
CREATE TYPE refund_status AS ENUM ('pending', 'accepted', 'rejected');

-- Create refunds table
CREATE TABLE refunds (
    id UUID NOT NULL DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    order_id TEXT NOT NULL,
    description TEXT,
    payment_method JSONB DEFAULT '{}',
    status refund_status NOT NULL DEFAULT 'pending',
    
    -- Primary key
    CONSTRAINT refunds_pkey PRIMARY KEY (id),
    
    -- Email validation
    CONSTRAINT check_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Create refunds storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) 
VALUES (
    'refunds', 
    'refunds', 
    FALSE,  -- Private bucket for refunds
    10485760,  -- 10MB limit
    ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/webp', 'text/plain']
);

-- Enable RLS on refunds table
ALTER TABLE refunds ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for refunds table
CREATE POLICY "Authenticated users can view their own refunds" ON refunds 
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can create refunds" ON refunds 
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update their own refunds" ON refunds 
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Create storage policies for refunds bucket
CREATE POLICY "Authenticated users can view refund files" ON storage.objects 
    FOR SELECT USING (bucket_id = 'refunds' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can upload refund files" ON storage.objects 
    FOR INSERT WITH CHECK (
        bucket_id = 'refunds' 
        AND auth.role() = 'authenticated'
    );

CREATE POLICY "Users can update their own refund files" ON storage.objects 
    FOR UPDATE USING (
        bucket_id = 'refunds' 
        AND auth.role() = 'authenticated'
    ) WITH CHECK (
        bucket_id = 'refunds' 
        AND auth.role() = 'authenticated'
    );

CREATE POLICY "Users can delete their own refund files" ON storage.objects 
    FOR DELETE USING (
        bucket_id = 'refunds' 
        AND auth.role() = 'authenticated'
    );

-- Create performance indexes
CREATE INDEX idx_refunds_email ON refunds(email);
CREATE INDEX idx_refunds_order_id ON refunds(order_id);
CREATE INDEX idx_refunds_created_at ON refunds(created_at);
CREATE INDEX idx_refunds_status ON refunds(status);

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_refunds_updated_at 
    BEFORE UPDATE ON refunds 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();