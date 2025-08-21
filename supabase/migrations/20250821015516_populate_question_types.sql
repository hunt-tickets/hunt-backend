-- Populate question_types with standard input types
INSERT INTO question_types (name, display_name) VALUES
('text', '{"en": "Text Field", "es": "Campo de Texto"}'),
('textarea', '{"en": "Text Area", "es": "Área de Texto"}'),
('dropdown', '{"en": "Dropdown Select", "es": "Selección Desplegable"}'),
('multiselect', '{"en": "Multiple Select", "es": "Selección Múltiple"}'),
('checkbox', '{"en": "Checkbox", "es": "Casilla de Verificación"}'),
('date', '{"en": "Date Picker", "es": "Selector de Fecha"}'),
('number', '{"en": "Number Field", "es": "Campo Numérico"}'),
('email', '{"en": "Email Field", "es": "Campo de Email"}'),
('tel', '{"en": "Phone Field", "es": "Campo de Teléfono"}'),
('url', '{"en": "URL Field", "es": "Campo de URL"}'),
('password', '{"en": "Password Field", "es": "Campo de Contraseña"}'),
('radio', '{"en": "Radio Buttons", "es": "Botones de Radio"}'),
('range', '{"en": "Range Slider", "es": "Control Deslizante"}'),
('file', '{"en": "File Upload", "es": "Subir Archivo"}'),
('color', '{"en": "Color Picker", "es": "Selector de Color"}');