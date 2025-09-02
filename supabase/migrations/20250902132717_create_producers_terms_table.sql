-- Create producers_terms table
-- Created 2025-09-02

-- Create producers_terms table
CREATE TABLE public.producers_terms (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    producer_id UUID NOT NULL,
    terms_and_conditions TEXT,
    privacy_policy TEXT,
    refund_policy TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY (producer_id) REFERENCES producers(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE producers_terms ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for producers_terms table
CREATE POLICY "Authenticated users can view producers terms" ON producers_terms 
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can create producers terms" ON producers_terms 
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update producers terms" ON producers_terms 
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can delete producers terms" ON producers_terms 
    FOR DELETE USING (auth.role() = 'authenticated');

-- Create performance indexes
CREATE INDEX idx_producers_terms_producer_id ON producers_terms(producer_id);
CREATE INDEX idx_producers_terms_created_at ON producers_terms(created_at);

-- Create unique constraint to ensure one terms record per producer
CREATE UNIQUE INDEX idx_producers_terms_unique_producer ON producers_terms(producer_id);

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_producers_terms_updated_at 
    BEFORE UPDATE ON producers_terms 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();