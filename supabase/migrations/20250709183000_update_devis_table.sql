-- Alter devis table to replace details with specific price fields
ALTER TABLE devis
DROP COLUMN details;

ALTER TABLE devis
ADD COLUMN prix_tolerie NUMERIC DEFAULT 0,
ADD COLUMN prix_mo NUMERIC DEFAULT 0,
ADD COLUMN prix_mecanique NUMERIC DEFAULT 0,
ADD COLUMN prix_electrique NUMERIC DEFAULT 0;

-- Also update bons_commande table as it seems to be related
ALTER TABLE bons_commande
DROP COLUMN details;

ALTER TABLE bons_commande
ADD COLUMN prix_tolerie NUMERIC DEFAULT 0,
ADD COLUMN prix_mo NUMERIC DEFAULT 0,
ADD COLUMN prix_mecanique NUMERIC DEFAULT 0,
ADD COLUMN prix_electrique NUMERIC DEFAULT 0;