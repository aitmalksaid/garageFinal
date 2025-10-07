-- Drop the existing articles table if it exists to avoid conflicts
DROP TABLE IF EXISTS public.articles;

-- Create the new articles table
CREATE TABLE public.articles (
    id bigint NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "Description" text NULL,
    "PrixHT" real NULL,
    "Fournisseur" bigint NULL,
    CONSTRAINT articles_fournisseur_fkey FOREIGN KEY ("Fournisseur") REFERENCES public.fournisseurs(id) ON DELETE SET NULL
);

-- Add comments to the table and columns for clarity
COMMENT ON TABLE public.articles IS 'Stores information about articles or parts';
COMMENT ON COLUMN public.articles.id IS 'Unique identifier for each article';
COMMENT ON COLUMN public.articles."Description" IS 'Description of the article';
COMMENT ON COLUMN public.articles."PrixHT" IS 'Price of the article before tax';
COMMENT ON COLUMN public.articles."Fournisseur" IS 'Foreign key to the fournisseurs table, can be null';