-- Create question_types table (catalog of input types)
CREATE TABLE question_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  display_name JSONB NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create events_checkout_questions table (direct event questions)
CREATE TABLE events_checkout_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL,
  question_type_id UUID NOT NULL,
  question_text JSONB NOT NULL,
  placeholder JSONB DEFAULT NULL,
  options JSONB DEFAULT NULL,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_required BOOLEAN DEFAULT false,
  applies_to JSONB DEFAULT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add foreign key constraints
ALTER TABLE events_checkout_questions 
ADD CONSTRAINT events_checkout_questions_event_id_fkey 
FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;

ALTER TABLE events_checkout_questions 
ADD CONSTRAINT events_checkout_questions_question_type_id_fkey 
FOREIGN KEY (question_type_id) REFERENCES question_types(id) ON DELETE RESTRICT;

-- Create indexes for efficient queries
CREATE INDEX idx_question_types_name ON question_types(name);
CREATE INDEX idx_question_types_active ON question_types(is_active);

CREATE INDEX idx_events_checkout_questions_event_id ON events_checkout_questions(event_id);
CREATE INDEX idx_events_checkout_questions_type_id ON events_checkout_questions(question_type_id);
CREATE INDEX idx_events_checkout_questions_order ON events_checkout_questions(event_id, order_index);
CREATE INDEX idx_events_checkout_questions_active ON events_checkout_questions(is_active);

-- Create triggers to auto-update updated_at timestamp
CREATE TRIGGER update_question_types_updated_at 
    BEFORE UPDATE ON question_types 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_checkout_questions_updated_at 
    BEFORE UPDATE ON events_checkout_questions 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE question_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE events_checkout_questions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for question_types
CREATE POLICY "Anyone can view active question types" ON question_types
    FOR SELECT USING (is_active = true);

CREATE POLICY "Authenticated users can manage question types" ON question_types
    FOR ALL USING (auth.role() = 'authenticated');

-- RLS Policies for events_checkout_questions
CREATE POLICY "Anyone can view active checkout questions" ON events_checkout_questions
    FOR SELECT USING (is_active = true);

CREATE POLICY "Authenticated users can manage checkout questions" ON events_checkout_questions
    FOR ALL USING (auth.role() = 'authenticated');