-- Forcer la mise à jour du schéma de la table devis_articles
-- Cette migration s'assure que la table existe avec la bonne structure

-- Drop et recrée la table pour forcer la mise à jour du cache
DROP TABLE IF EXISTS devis_articles CASCADE;

-- Recrée la table avec la structure correcte
CREATE TABLE devis_articles (
    id SERIAL PRIMARY KEY,
    devis_id INTEGER NOT NULL REFERENCES devis(id) ON DELETE CASCADE,
    article_id INTEGER REFERENCES articles(id),
    description TEXT NOT NULL,
    quantite INTEGER NOT NULL DEFAULT 1,
    prix_ht DECIMAL(10,2) NOT NULL DEFAULT 0,
    fournisseur_id INTEGER REFERENCES fournisseurs(id),
    intervention VARCHAR(50) DEFAULT 'REMPLACEMENT',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Recrée les index
CREATE INDEX idx_devis_articles_devis_id ON devis_articles(devis_id);
CREATE INDEX idx_devis_articles_article_id ON devis_articles(article_id);
CREATE INDEX idx_devis_articles_fournisseur_id ON devis_articles(fournisseur_id);

-- Commenter la table et les colonnes pour la documentation
COMMENT ON TABLE devis_articles IS 'Table des articles associés aux devis';
COMMENT ON COLUMN devis_articles.devis_id IS 'ID du devis parent';
COMMENT ON COLUMN devis_articles.article_id IS 'ID de l''article de référence (optionnel)';
COMMENT ON COLUMN devis_articles.description IS 'Description de l''article';
COMMENT ON COLUMN devis_articles.quantite IS 'Quantité commandée';
COMMENT ON COLUMN devis_articles.prix_ht IS 'Prix unitaire HT';
COMMENT ON COLUMN devis_articles.fournisseur_id IS 'ID du fournisseur';
COMMENT ON COLUMN devis_articles.intervention IS 'Type d''intervention';
