-- ================================================================
--  GestiQ — Migration 019: Align team_members schema with the form
--  Date: 2026-04-26
--
--  The Equipe form sends `prenom`, `poste`, `salaire_base`, plus
--  lowercase role/statut values that the existing CHECK constraints
--  reject. Add the missing columns + relax the constraints so the
--  form can finally insert without 500ing.
-- ================================================================

BEGIN;

ALTER TABLE public.team_members
  ADD COLUMN IF NOT EXISTS prenom        text,
  ADD COLUMN IF NOT EXISTS poste         text,
  ADD COLUMN IF NOT EXISTS salaire_base  numeric;

-- Backfill salaire_base from the legacy salaire_mensuel column when
-- it exists, so existing rows keep their amount visible in the UI.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
     WHERE table_schema = 'public'
       AND table_name   = 'team_members'
       AND column_name  = 'salaire_mensuel'
  ) THEN
    EXECUTE 'UPDATE public.team_members
                SET salaire_base = COALESCE(salaire_base, salaire_mensuel)
              WHERE salaire_base IS NULL';
  END IF;
END $$;

-- Relax CHECK constraints — both the legacy capitalized values and
-- the lowercase ones the new form sends are accepted.
ALTER TABLE public.team_members DROP CONSTRAINT IF EXISTS team_members_role_check;
ALTER TABLE public.team_members
  ADD CONSTRAINT team_members_role_check
  CHECK (role IN (
    'admin','manager','commercial','comptable','viewer',
    'Admin','Employé','Stagiaire'
  ));

ALTER TABLE public.team_members DROP CONSTRAINT IF EXISTS team_members_statut_check;
ALTER TABLE public.team_members
  ADD CONSTRAINT team_members_statut_check
  CHECK (statut IN ('actif','inactif','Actif','Inactif'));

COMMIT;
