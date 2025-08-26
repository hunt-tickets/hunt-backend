-- Add invoice file synchronization
-- Created 2025-08-26

-- Function to delete invoice file when invoice is deleted
CREATE OR REPLACE FUNCTION delete_invoice_file()
RETURNS TRIGGER AS $$
BEGIN
    -- Try to delete the file, ignore if it doesn't exist
    PERFORM storage.delete_object('invoice', 'main/' || OLD.id::text);
    RETURN OLD;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail the deletion
        RAISE WARNING 'Could not delete file for invoice %: %', OLD.id, SQLERRM;
        RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Function to manually delete orphaned invoices (when file is deleted first)
CREATE OR REPLACE FUNCTION delete_orphaned_invoice(invoice_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
    file_exists BOOLEAN := FALSE;
    invoice_exists BOOLEAN := FALSE;
BEGIN
    -- Check if file exists
    SELECT EXISTS(
        SELECT 1 FROM storage.objects 
        WHERE bucket_id = 'invoice' 
        AND name = 'main/' || invoice_uuid::text
    ) INTO file_exists;
    
    -- Check if invoice exists
    SELECT EXISTS(
        SELECT 1 FROM invoices 
        WHERE id = invoice_uuid
    ) INTO invoice_exists;
    
    -- If invoice exists but file doesn't, delete the invoice
    IF invoice_exists AND NOT file_exists THEN
        DELETE FROM invoices WHERE id = invoice_uuid;
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Could not delete orphaned invoice %: %', invoice_uuid, SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically delete file when invoice is deleted
CREATE TRIGGER trigger_delete_invoice_file
    AFTER DELETE ON invoices
    FOR EACH ROW
    EXECUTE FUNCTION delete_invoice_file();

-- Update storage policy to allow access to main/ folder
CREATE POLICY "Authenticated users can upload to main folder" ON storage.objects 
    FOR INSERT WITH CHECK (
        bucket_id = 'invoice' 
        AND auth.role() = 'authenticated'
        AND (storage.foldername(name))[1] = 'main'
    );