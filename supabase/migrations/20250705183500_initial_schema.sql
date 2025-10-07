-- Create clients table
CREATE TABLE clients (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ DEFAULT now(),
    nom TEXT,
    prenom TEXT,
    adresse TEXT,
    telephone TEXT,
    email TEXT
);

-- Create voitures (vehicles) table
CREATE TABLE voitures (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ DEFAULT now(),
    marque TEXT,
    modele TEXT,
    immatriculation TEXT UNIQUE,
    client_id BIGINT REFERENCES clients(id)
);

-- Create experts table
CREATE TABLE experts (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ DEFAULT now(),
    nom TEXT,
    prenom TEXT,
    telephone TEXT,
    email TEXT
);

-- Create assurances (insurances) table
CREATE TABLE assurances (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ DEFAULT now(),
    nom TEXT,
    adresse TEXT,
    telephone TEXT
);

-- Create fournisseurs (suppliers) table
CREATE TABLE fournisseurs (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ DEFAULT now(),
    nom TEXT,
    adresse TEXT,
    telephone TEXT,
    email TEXT
);

-- Create affaires (cases) table
CREATE TABLE affaires (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ DEFAULT now(),
    numero_affaire TEXT UNIQUE,
    date_ouverture DATE,
    voiture_id BIGINT REFERENCES voitures(id),
    client_id BIGINT REFERENCES clients(id),
    assurance_id BIGINT REFERENCES assurances(id),
    expert_id BIGINT REFERENCES experts(id),
    statut TEXT
);

-- Create devis (quotes) table
CREATE TABLE devis (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ DEFAULT now(),
    affaire_id BIGINT REFERENCES affaires(id),
    numero_devis TEXT UNIQUE,
    date_devis DATE,
    montant_ht NUMERIC,
    montant_tva NUMERIC,
    montant_ttc NUMERIC,
    details JSONB
);

-- Create bons_commande (orders) table
CREATE TABLE bons_commande (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ DEFAULT now(),
    affaire_id BIGINT REFERENCES affaires(id),
    fournisseur_id BIGINT REFERENCES fournisseurs(id),
    numero_bon TEXT UNIQUE,
    date_commande DATE,
    montant_total NUMERIC,
    details JSONB
);

-- Create benefices (profits) table
CREATE TABLE benefices (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ DEFAULT now(),
    affaire_id BIGINT REFERENCES affaires(id),
    montant NUMERIC,
    description TEXT,
    date DATE
);