-- Convert category column from TEXT to JSONB with multilanguage support
-- Transform existing categories and add all new category types

-- Step 1: Create a temporary JSONB column
ALTER TABLE public.events ADD COLUMN category_jsonb JSONB;

-- Step 2: Migrate existing category data to JSONB format
-- Map old TEXT categories to new JSONB structure
UPDATE public.events SET category_jsonb = 
    CASE 
        WHEN category = 'concert' THEN '{"en": "Music", "es": "Musica"}'
        WHEN category = 'theater' THEN '{"en": "Performing & Visual Arts", "es": "Artes Escenicas y Visuales"}'
        WHEN category = 'sports' THEN '{"en": "Sports & Fitness", "es": "Deportes y Fitness"}'
        WHEN category = 'conference' THEN '{"en": "Business & Professional", "es": "Negocios y Profesional"}'
        WHEN category = 'general' THEN '{"en": "Other", "es": "Otro"}'
        ELSE '{"en": "Other", "es": "Otro"}'
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

-- Step 10: Create a view for easy category lookup
CREATE OR REPLACE VIEW event_categories_catalog AS
SELECT 
    jsonb_build_object('en', en_name, 'es', es_name) as category,
    en_name,
    es_name,
    ROW_NUMBER() OVER (ORDER BY en_name) as sort_order
FROM (
    VALUES 
        ('Auto, Boat & Air', 'Auto, Barco y Aire'),
        ('Business & Professional', 'Negocios y Profesional'),
        ('Charity & Causes', 'Caridad y Causas'),
        ('Community & Culture', 'Comunidad y Cultura'),
        ('Family & Education', 'Familia y Educacion'),
        ('Fashion & Beauty', 'Moda y Belleza'),
        ('Film, Media & Entertainment', 'Cine, Medios y Entretenimiento'),
        ('Food & Drink', 'Comida y Bebida'),
        ('Government & Politics', 'Gobierno y Politica'),
        ('Health & Wellness', 'Salud y Bienestar'),
        ('Hobbies & Special Interest', 'Pasatiempos e Interes Especial'),
        ('Home & Lifestyle', 'Hogar y Estilo de Vida'),
        ('Music', 'Musica'),
        ('Performing & Visual Arts', 'Artes Escenicas y Visuales'),
        ('Religion & Spirituality', 'Religion y Espiritualidad'),
        ('School Activities', 'Actividades Escolares'),
        ('Science & Technology', 'Ciencia y Tecnologia'),
        ('Seasonal & Holiday', 'Estacional y Vacaciones'),
        ('Sports & Fitness', 'Deportes y Fitness'),
        ('Travel & Outdoor', 'Viajes y Aire Libre'),
        ('Other', 'Otro')
) AS categories(en_name, es_name);

-- Step 11: Add comment to catalog view
COMMENT ON VIEW event_categories_catalog IS 
'Catalog view of all available event categories with English and Spanish translations. 
Use this view to populate dropdowns in applications.';