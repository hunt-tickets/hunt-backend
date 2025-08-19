-- Tabla de prueba en esquema público
CREATE TABLE public.test_table (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS (Row Level Security)
ALTER TABLE public.test_table ENABLE ROW LEVEL SECURITY;

-- Política básica para permitir lectura a todos los usuarios autenticados
CREATE POLICY "Allow read access to authenticated users" 
ON public.test_table 
FOR SELECT 
TO authenticated 
USING (true);

-- Política para permitir inserción a usuarios autenticados
CREATE POLICY "Allow insert access to authenticated users" 
ON public.test_table 
FOR INSERT 
TO authenticated 
WITH CHECK (true);