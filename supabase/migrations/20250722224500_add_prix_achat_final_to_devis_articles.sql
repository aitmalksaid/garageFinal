-- Add prix_achat_final column to devis_articles table
ALTER TABLE devis_articles
ADD COLUMN prix_achat_final DECIMAL(10, 2) NOT NULL DEFAULT 0;

-- Add comment to the new column
COMMENT ON COLUMN devis_articles.prix_achat_final IS 'Prix d''achat final de l''article';