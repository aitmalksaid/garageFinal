-- Ajouter les colonnes de suivi des réparations à devis_articles
ALTER TABLE devis_articles 
ADD COLUMN statut_reparation VARCHAR(50) DEFAULT 'EN_ATTENTE' CHECK (statut_reparation IN ('EN_ATTENTE', 'COMMANDE', 'RECU', 'EN_COURS', 'TERMINE', 'POSE')),
ADD COLUMN date_commande DATE,
ADD COLUMN date_reception DATE,
ADD COLUMN date_debut_reparation DATE,
ADD COLUMN date_fin_reparation DATE,
ADD COLUMN date_pose DATE,
ADD COLUMN technicien_assigne VARCHAR(100),
ADD COLUMN notes_reparation TEXT,
ADD COLUMN temps_estime_heures DECIMAL(5,2),
ADD COLUMN temps_reel_heures DECIMAL(5,2),
ADD COLUMN priorite VARCHAR(20) DEFAULT 'NORMALE' CHECK (priorite IN ('BASSE', 'NORMALE', 'HAUTE', 'URGENTE'));

-- Créer un index pour les recherches par statut
CREATE INDEX IF NOT EXISTS idx_devis_articles_statut_reparation ON devis_articles(statut_reparation);
CREATE INDEX IF NOT EXISTS idx_devis_articles_technicien ON devis_articles(technicien_assigne);