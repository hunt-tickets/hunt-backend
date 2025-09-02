-- Allow anonymous users to upload files to refunds bucket
-- Created 2025-08-26

-- Policy to allow anonymous users to upload files to refunds bucket
CREATE POLICY "Anonymous users can upload refund files" ON storage.objects 
    FOR INSERT WITH CHECK (
        bucket_id = 'refunds' 
        AND auth.role() = 'anon'
    );