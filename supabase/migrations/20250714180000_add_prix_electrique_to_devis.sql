-- Add prix_electrique column to devis table if it doesn't exist
ALTER TABLE devis 
ADD COLUMN IF NOT EXISTS prix_electrique DECIMAL(10,2) DEFAULT 0;
