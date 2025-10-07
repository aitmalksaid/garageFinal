-- Rename prix columns to MO columns in devis table
ALTER TABLE devis 
RENAME COLUMN prix_tolerie TO MO_tolerie;

ALTER TABLE devis 
RENAME COLUMN prix_mo TO MO_peinture;

ALTER TABLE devis 
RENAME COLUMN prix_mecanique TO MO_mecanique;

ALTER TABLE devis 
RENAME COLUMN prix_electrique TO MO_electrique;
