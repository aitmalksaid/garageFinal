CREATE TABLE statuts (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(50) NOT NULL,
  couleur VARCHAR(20) NOT NULL
);

CREATE TABLE devis (
  id SERIAL PRIMARY KEY,
  client VARCHAR(100) NOT NULL,
  vehicule VARCHAR(100) NOT NULL,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE items_devis (
  id SERIAL PRIMARY KEY,
  devis_id INT NOT NULL,
  designation VARCHAR(100) NOT NULL,
  reference VARCHAR(50) NOT NULL,
  statut_id INT NOT NULL,
  FOREIGN KEY (devis_id) REFERENCES devis(id) ON DELETE CASCADE,
  FOREIGN KEY (statut_id) REFERENCES statuts(id)
);

CREATE OR REPLACE FUNCTION update_modified_column() 
RETURNS TRIGGER AS $$
BEGIN
   NEW.date_modification = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_devis_modtime BEFORE UPDATE ON devis FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- Insertion des statuts initiaux
INSERT INTO statuts (nom, couleur) VALUES
('En recherche', 'yellow'),
('En attente pièce', 'orange'),
('En cours de montage', 'blue'),
('Terminé', 'green');

CREATE INDEX idx_items_devis ON items_devis(devis_id, statut_id);