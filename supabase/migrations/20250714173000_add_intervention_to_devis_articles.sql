-- Add intervention column to devis_articles table
ALTER TABLE devis_articles 
ADD COLUMN intervention VARCHAR(50) DEFAULT 'REMPLACEMENT' CHECK (intervention IN ('REMPLACEMENT', 'OCCASION', 'REDRESSAGE', 'ADAPTABLE', 'ORIGINE'));

-- Update existing records to have default intervention
UPDATE devis_articles SET intervention = 'REMPLACEMENT' WHERE intervention IS NULL;
