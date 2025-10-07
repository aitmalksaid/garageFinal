-- Create devis_articles table
CREATE TABLE IF NOT EXISTS devis_articles (
    id SERIAL PRIMARY KEY,
    devis_id INTEGER REFERENCES devis(id) ON DELETE CASCADE,
    article_id INTEGER REFERENCES articles(id),
    description TEXT,
    quantite INTEGER NOT NULL DEFAULT 1,
    prix_ht DECIMAL(10,2) NOT NULL DEFAULT 0,
    fournisseur_id INTEGER REFERENCES fournisseurs(id),
    intervention VARCHAR(50) DEFAULT 'REMPLACEMENT',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_devis_articles_devis_id ON devis_articles(devis_id);
CREATE INDEX IF NOT EXISTS idx_devis_articles_article_id ON devis_articles(article_id);
CREATE INDEX IF NOT EXISTS idx_devis_articles_fournisseur_id ON devis_articles(fournisseur_id);
