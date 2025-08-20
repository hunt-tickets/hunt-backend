-- Add event_type JSONB column with multilanguage support to events table
-- Similar to currencies table with translations

-- Add event_type column as JSONB with default value
ALTER TABLE public.events ADD COLUMN event_type JSONB DEFAULT '{"en": "Other", "es": "Otro"}';

-- Create constraint to validate event_type structure and allowed values
ALTER TABLE public.events ADD CONSTRAINT events_event_type_valid_structure 
CHECK (
    event_type ? 'en' AND event_type ? 'es' AND
    jsonb_typeof(event_type->'en') = 'string' AND
    jsonb_typeof(event_type->'es') = 'string'
);

-- Create constraint to validate allowed event type values
ALTER TABLE public.events ADD CONSTRAINT events_event_type_valid_values 
CHECK (
    event_type->>'en' IN (
        'Appearance or Signing',
        'Attraction', 
        'Camp, Trip or Retreat',
        'Class, Training or Workshop',
        'Concert or Performance',
        'Conference',
        'Convention',
        'Dinner or Gala',
        'Festival or Fair',
        'Game or Competition',
        'Meeting or Networking Event',
        'Party or Social Gathering',
        'Race or Endurance Event',
        'Rally',
        'Screening',
        'Seminar or Talk',
        'Tour',
        'Tournament',
        'Trade Show, Consumer Show or Expo',
        'Other'
    )
    AND
    event_type->>'es' IN (
        'Aparicion o Firma',
        'Atraccion',
        'Campamento, Viaje o Retiro',
        'Clase, Entrenamiento o Taller',
        'Concierto o Presentacion',
        'Conferencia',
        'Convencion',
        'Cena o Gala',
        'Festival o Feria',
        'Juego o Competencia',
        'Reunion o Evento de Networking',
        'Fiesta o Reunion Social',
        'Carrera o Evento de Resistencia',
        'Rally',
        'Proyeccion',
        'Seminario o Charla',
        'Tour',
        'Torneo',
        'Feria Comercial, Feria de Consumo o Expo',
        'Otro'
    )
);

-- Create GIN index for efficient JSONB queries
CREATE INDEX idx_events_event_type_gin ON public.events USING GIN (event_type);

-- Create functional indexes for language-specific searches
CREATE INDEX idx_events_event_type_en ON public.events ((event_type->>'en'));
CREATE INDEX idx_events_event_type_es ON public.events ((event_type->>'es'));

-- Update existing events to have default event_type
UPDATE public.events 
SET event_type = '{"en": "Other", "es": "Otro"}'
WHERE event_type IS NULL;

-- Add helpful comment
COMMENT ON COLUMN public.events.event_type IS 
'Event type with multilanguage support. Structure: {"en": "English Name", "es": "Spanish Name"}. 
Supports 20 different event categories from appearance/signing to trade shows.';

-- Create a view for easy event type lookup
CREATE OR REPLACE VIEW event_types_catalog AS
SELECT 
    jsonb_build_object('en', en_name, 'es', es_name) as event_type,
    en_name,
    es_name,
    ROW_NUMBER() OVER (ORDER BY en_name) as sort_order
FROM (
    VALUES 
        ('Appearance or Signing', 'Aparicion o Firma'),
        ('Attraction', 'Atraccion'), 
        ('Camp, Trip or Retreat', 'Campamento, Viaje o Retiro'),
        ('Class, Training or Workshop', 'Clase, Entrenamiento o Taller'),
        ('Concert or Performance', 'Concierto o Presentacion'),
        ('Conference', 'Conferencia'),
        ('Convention', 'Convencion'),
        ('Dinner or Gala', 'Cena o Gala'),
        ('Festival or Fair', 'Festival o Feria'),
        ('Game or Competition', 'Juego o Competencia'),
        ('Meeting or Networking Event', 'Reunion o Evento de Networking'),
        ('Party or Social Gathering', 'Fiesta o Reunion Social'),
        ('Race or Endurance Event', 'Carrera o Evento de Resistencia'),
        ('Rally', 'Rally'),
        ('Screening', 'Proyeccion'),
        ('Seminar or Talk', 'Seminario o Charla'),
        ('Tour', 'Tour'),
        ('Tournament', 'Torneo'),
        ('Trade Show, Consumer Show or Expo', 'Feria Comercial, Feria de Consumo o Expo'),
        ('Other', 'Otro')
) AS event_types(en_name, es_name);

-- Add RLS policy comment
COMMENT ON VIEW event_types_catalog IS 
'Catalog view of all available event types with English and Spanish translations. 
Use this view to populate dropdowns in applications.';