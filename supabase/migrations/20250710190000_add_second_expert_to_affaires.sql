ALTER TABLE public.affaires
ADD COLUMN expert_id_2 bigint,
ADD CONSTRAINT affaires_expert_id_2_fkey FOREIGN KEY (expert_id_2) REFERENCES public.experts(id) ON DELETE SET NULL;

COMMENT ON COLUMN public.affaires.expert_id_2 IS 'Optional foreign key for a second expert';