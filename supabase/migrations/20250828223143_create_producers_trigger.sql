-- Create trigger function to automatically create empty producers_social_media record
-- when a new producer is created

CREATE OR REPLACE FUNCTION create_producer_social_media()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO producers_social_media (producer_id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger that fires after INSERT on producers table
CREATE TRIGGER trigger_create_producer_social_media
  AFTER INSERT ON producers
  FOR EACH ROW
  EXECUTE FUNCTION create_producer_social_media();