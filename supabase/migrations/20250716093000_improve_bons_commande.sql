-- Améliorer la table bons_commande
ALTER TABLE bons_commande ADD COLUMN IF NOT EXISTS statut TEXT DEFAULT 'brouillon';
ALTER TABLE bons_commande ADD COLUMN IF NOT EXISTS devis_id BIGINT REFERENCES devis(id);
ALTER TABLE bons_commande ADD COLUMN IF NOT EXISTS date_prevue_livraison DATE;
ALTER TABLE bons_commande ADD COLUMN IF NOT EXISTS notes TEXT;

-- Créer la table bons_commande_articles pour gérer les articles individuels
CREATE TABLE IF NOT EXISTS bons_commande_articles (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ DEFAULT now(),
    bon_commande_id BIGINT REFERENCES bons_commande(id) ON DELETE CASCADE,
    article_id BIGINT REFERENCES articles(id),
    description TEXT NOT NULL,
    quantite INTEGER NOT NULL DEFAULT 1,
    prix_unitaire NUMERIC NOT NULL DEFAULT 0,
    total_ht NUMERIC NOT NULL DEFAULT 0,
    statut TEXT DEFAULT 'en_attente', -- 'en_attente', 'commande', 'recu', 'monte'
    date_reception DATE,
    notes TEXT,
    intervention TEXT
);

-- Créer des index pour optimiser les performances
CREATE INDEX IF NOT EXISTS idx_bons_commande_articles_bon_commande_id ON bons_commande_articles(bon_commande_id);
CREATE INDEX IF NOT EXISTS idx_bons_commande_articles_article_id ON bons_commande_articles(article_id);
CREATE INDEX IF NOT EXISTS idx_bons_commande_devis_id ON bons_commande(devis_id);
CREATE INDEX IF NOT EXISTS idx_bons_commande_statut ON bons_commande(statut);

-- Fonction pour générer le numéro de bon de commande
CREATE OR REPLACE FUNCTION generate_bon_commande_number()
RETURNS TEXT AS $$
DECLARE
    current_year TEXT;
    next_number INTEGER;
    formatted_number TEXT;
BEGIN
    -- Obtenir l'année actuelle (2 derniers chiffres)
    current_year := EXTRACT(YEAR FROM CURRENT_DATE)::TEXT;
    current_year := RIGHT(current_year, 2);
    
    -- Compter les bons de commande existants pour cette année
    SELECT COUNT(*) + 1 INTO next_number
    FROM bons_commande
    WHERE numero_bon LIKE current_year || 'BC%';
    
    -- Formater le numéro avec des zéros en préfixe
    formatted_number := LPAD(next_number::TEXT, 5, '0');
    
    RETURN current_year || 'BC' || formatted_number;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour générer automatiquement le numéro de bon de commande
CREATE OR REPLACE FUNCTION set_bon_commande_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.numero_bon IS NULL THEN
        NEW.numero_bon := generate_bon_commande_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Supprimer le trigger existant s'il existe
DROP TRIGGER IF EXISTS trigger_set_bon_commande_number ON bons_commande;

-- Créer le trigger
CREATE TRIGGER trigger_set_bon_commande_number
    BEFORE INSERT ON bons_commande
    FOR EACH ROW
    EXECUTE FUNCTION set_bon_commande_number();

-- Fonction pour calculer le total HT d'un bon de commande
CREATE OR REPLACE FUNCTION calculate_bon_commande_total(bon_id BIGINT)
RETURNS NUMERIC AS $$
DECLARE
    total_ht NUMERIC DEFAULT 0;
BEGIN
    SELECT COALESCE(SUM(total_ht), 0) INTO total_ht
    FROM bons_commande_articles
    WHERE bon_commande_id = bon_id;
    
    RETURN total_ht;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour automatiquement le total du bon de commande
CREATE OR REPLACE FUNCTION update_bon_commande_total()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        UPDATE bons_commande 
        SET montant_total = calculate_bon_commande_total(OLD.bon_commande_id)
        WHERE id = OLD.bon_commande_id;
        RETURN OLD;
    ELSE
        UPDATE bons_commande 
        SET montant_total = calculate_bon_commande_total(NEW.bon_commande_id)
        WHERE id = NEW.bon_commande_id;
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_bon_commande_total
    AFTER INSERT OR UPDATE OR DELETE ON bons_commande_articles
    FOR EACH ROW
    EXECUTE FUNCTION update_bon_commande_total();
