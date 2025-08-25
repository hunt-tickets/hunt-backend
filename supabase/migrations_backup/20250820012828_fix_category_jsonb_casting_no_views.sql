-- Fix category column conversion to JSONB with proper casting
-- Convert existing TEXT category to JSONB multilanguage format

-- Step 1: Create a temporary JSONB column
ALTER TABLE public.events ADD COLUMN category_jsonb JSONB;

-- Step 2: Migrate existing category data to JSONB format with proper casting
-- Map old TEXT categories to new JSONB structure using jsonb_build_object
UPDATE public.events SET category_jsonb = 
    CASE 
        WHEN category = 'concert' THEN jsonb_build_object('en', 'Music', 'es', 'Musica')
        WHEN category = 'theater' THEN jsonb_build_object('en', 'Performing & Visual Arts', 'es', 'Artes Escenicas y Visuales')
        WHEN category = 'sports' THEN jsonb_build_object('en', 'Sports & Fitness', 'es', 'Deportes y Fitness')
        WHEN category = 'conference' THEN jsonb_build_object('en', 'Business & Professional', 'es', 'Negocios y Profesional')
        WHEN category = 'general' THEN jsonb_build_object('en', 'Other', 'es', 'Otro')
        ELSE jsonb_build_object('en', 'Other', 'es', 'Otro')
    END;

-- Step 3: Drop old category column and rename new one
ALTER TABLE public.events DROP COLUMN category;
ALTER TABLE public.events RENAME COLUMN category_jsonb TO category;

-- Step 4: Set default value for new category column
ALTER TABLE public.events ALTER COLUMN category SET DEFAULT '{"en": "Other", "es": "Otro"}';

-- Step 5: Create constraint to validate category structure
ALTER TABLE public.events ADD CONSTRAINT events_category_valid_structure 
CHECK (
    category ? 'en' AND category ? 'es' AND
    jsonb_typeof(category->'en') = 'string' AND
    jsonb_typeof(category->'es') = 'string'
);

-- Step 6: Create constraint to validate allowed category values
ALTER TABLE public.events ADD CONSTRAINT events_category_valid_values 
CHECK (
    category->>'en' IN (
        'Auto, Boat & Air',
        'Business & Professional',
        'Charity & Causes',
        'Community & Culture',
        'Family & Education',
        'Fashion & Beauty',
        'Film, Media & Entertainment',
        'Food & Drink',
        'Government & Politics',
        'Health & Wellness',
        'Hobbies & Special Interest',
        'Home & Lifestyle',
        'Music',
        'Performing & Visual Arts',
        'Religion & Spirituality',
        'School Activities',
        'Science & Technology',
        'Seasonal & Holiday',
        'Sports & Fitness',
        'Travel & Outdoor',
        'Other'
    )
    AND
    category->>'es' IN (
        'Auto, Barco y Aire',
        'Negocios y Profesional',
        'Caridad y Causas',
        'Comunidad y Cultura',
        'Familia y Educacion',
        'Moda y Belleza',
        'Cine, Medios y Entretenimiento',
        'Comida y Bebida',
        'Gobierno y Politica',
        'Salud y Bienestar',
        'Pasatiempos e Interes Especial',
        'Hogar y Estilo de Vida',
        'Musica',
        'Artes Escenicas y Visuales',
        'Religion y Espiritualidad',
        'Actividades Escolares',
        'Ciencia y Tecnologia',
        'Estacional y Vacaciones',
        'Deportes y Fitness',
        'Viajes y Aire Libre',
        'Otro'
    )
);

-- Step 7: Create indexes for efficient JSONB queries
CREATE INDEX idx_events_category_gin ON public.events USING GIN (category);
CREATE INDEX idx_events_category_en ON public.events ((category->>'en'));
CREATE INDEX idx_events_category_es ON public.events ((category->>'es'));

-- Step 8: Update existing indexes that referenced the old category column
DROP INDEX IF EXISTS idx_events_category;

-- Step 9: Add helpful comment
COMMENT ON COLUMN public.events.category IS 
'Event category with multilanguage support. Structure: {"en": "English Name", "es": "Spanish Name"}. 
Supports 20 different categories from Auto/Boat/Air to Travel/Outdoor.';