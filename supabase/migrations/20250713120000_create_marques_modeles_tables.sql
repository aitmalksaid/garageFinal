-- Create marques (brands) table
CREATE TABLE marques (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ DEFAULT now(),
    nom TEXT NOT NULL UNIQUE,
    pays TEXT,
    actif BOOLEAN DEFAULT true
);

-- Create modeles (models) table
CREATE TABLE modeles (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ DEFAULT now(),
    nom TEXT NOT NULL,
    marque_id BIGINT REFERENCES marques(id) ON DELETE CASCADE,
    actif BOOLEAN DEFAULT true,
    UNIQUE(nom, marque_id)
);

-- Insert predefined brands
INSERT INTO marques (nom, pays) VALUES
('Peugeot', 'France'),
('Citroën', 'France'),
('Renault', 'France'),
('Dacia', 'Roumanie'),
('Ford', 'États-Unis'),
('Volkswagen', 'Allemagne'),
('Mercedes-Benz', 'Allemagne'),
('BMW', 'Allemagne'),
('Audi', 'Allemagne'),
('Toyota', 'Japon'),
('Hyundai', 'Corée du Sud'),
('Kia', 'Corée du Sud'),
('Fiat', 'Italie'),
('Opel', 'Allemagne'),
('Skoda', 'République tchèque');

-- Insert predefined models for each brand
-- Peugeot models
INSERT INTO modeles (nom, marque_id) 
SELECT unnest(ARRAY['208', '308', '508', '2008', '3008', '5008', 'Partner']), id 
FROM marques WHERE nom = 'Peugeot';

-- Citroën models
INSERT INTO modeles (nom, marque_id) 
SELECT unnest(ARRAY['C3', 'C4', 'C5 Aircross', 'Berlingo', 'Jumpy']), id 
FROM marques WHERE nom = 'Citroën';

-- Renault models
INSERT INTO modeles (nom, marque_id) 
SELECT unnest(ARRAY['Clio', 'Megane', 'Captur', 'Kadjar', 'Kangoo']), id 
FROM marques WHERE nom = 'Renault';

-- Dacia models
INSERT INTO modeles (nom, marque_id) 
SELECT unnest(ARRAY['Sandero', 'Logan', 'Duster', 'Spring']), id 
FROM marques WHERE nom = 'Dacia';

-- Ford models
INSERT INTO modeles (nom, marque_id) 
SELECT unnest(ARRAY['Fiesta', 'Focus', 'Puma', 'Kuga', 'Ranger']), id 
FROM marques WHERE nom = 'Ford';

-- Volkswagen models
INSERT INTO modeles (nom, marque_id) 
SELECT unnest(ARRAY['Polo', 'Golf', 'T-Roc', 'Tiguan', 'Passat']), id 
FROM marques WHERE nom = 'Volkswagen';

-- Mercedes-Benz models
INSERT INTO modeles (nom, marque_id) 
SELECT unnest(ARRAY['Classe A', 'Classe C', 'Classe E', 'GLA', 'GLC']), id 
FROM marques WHERE nom = 'Mercedes-Benz';

-- BMW models
INSERT INTO modeles (nom, marque_id) 
SELECT unnest(ARRAY['Série 1', 'Série 3', 'Série 5', 'X1', 'X3', 'X5']), id 
FROM marques WHERE nom = 'BMW';

-- Audi models
INSERT INTO modeles (nom, marque_id) 
SELECT unnest(ARRAY['A1', 'A3', 'A4', 'Q2', 'Q3', 'Q5']), id 
FROM marques WHERE nom = 'Audi';

-- Toyota models
INSERT INTO modeles (nom, marque_id) 
SELECT unnest(ARRAY['Yaris', 'Corolla', 'C-HR', 'RAV4', 'Hilux']), id 
FROM marques WHERE nom = 'Toyota';

-- Hyundai models
INSERT INTO modeles (nom, marque_id) 
SELECT unnest(ARRAY['i10', 'i20', 'i30', 'Tucson', 'Kona']), id 
FROM marques WHERE nom = 'Hyundai';

-- Kia models
INSERT INTO modeles (nom, marque_id) 
SELECT unnest(ARRAY['Picanto', 'Rio', 'Ceed', 'Sportage', 'Stonic']), id 
FROM marques WHERE nom = 'Kia';

-- Fiat models
INSERT INTO modeles (nom, marque_id) 
SELECT unnest(ARRAY['500', 'Panda', 'Tipo', 'Fiorino']), id 
FROM marques WHERE nom = 'Fiat';

-- Opel models
INSERT INTO modeles (nom, marque_id) 
SELECT unnest(ARRAY['Corsa', 'Astra', 'Mokka', 'Crossland']), id 
FROM marques WHERE nom = 'Opel';

-- Skoda models
INSERT INTO modeles (nom, marque_id) 
SELECT unnest(ARRAY['Fabia', 'Octavia', 'Kamiq', 'Karoq']), id 
FROM marques WHERE nom = 'Skoda';
