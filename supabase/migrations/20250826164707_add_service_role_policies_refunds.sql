-- Add service_role policies for refunds table and bucket
-- Created 2025-08-26

-- Service role policies for refunds table
CREATE POLICY "Service role can view all refunds" ON refunds 
    FOR SELECT USING (auth.role() = 'service_role');

CREATE POLICY "Service role can create refunds" ON refunds 
    FOR INSERT WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "Service role can update all refunds" ON refunds 
    FOR UPDATE USING (auth.role() = 'service_role');

CREATE POLICY "Service role can delete refunds" ON refunds 
    FOR DELETE USING (auth.role() = 'service_role');

-- Service role policies for refunds storage bucket
CREATE POLICY "Service role can view all refund files" ON storage.objects 
    FOR SELECT USING (bucket_id = 'refunds' AND auth.role() = 'service_role');

CREATE POLICY "Service role can upload refund files" ON storage.objects 
    FOR INSERT WITH CHECK (
        bucket_id = 'refunds' 
        AND auth.role() = 'service_role'
    );

CREATE POLICY "Service role can update all refund files" ON storage.objects 
    FOR UPDATE USING (
        bucket_id = 'refunds' 
        AND auth.role() = 'service_role'
    ) WITH CHECK (
        bucket_id = 'refunds' 
        AND auth.role() = 'service_role'
    );

CREATE POLICY "Service role can delete all refund files" ON storage.objects 
    FOR DELETE USING (
        bucket_id = 'refunds' 
        AND auth.role() = 'service_role'
    );