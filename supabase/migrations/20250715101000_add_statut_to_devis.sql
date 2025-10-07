ALTER TABLE public.devis
ADD COLUMN IF NOT EXISTS statut TEXT DEFAULT 'nouveau Devis';
