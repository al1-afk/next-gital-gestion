-- ─────────────────────────────────────────────────────────────
-- 010_align_contrats_schema.sql
-- Same class of fix as 009 — align the live `contrats` table
-- with what src/pages/Contrats.tsx actually sends. The live DB
-- still had the pre-retrofit names (reference, total_convenu,
-- date_contrat, date_echeance, statut_contrat) so every INSERT
-- was failing with `column "numero" does not exist`.
--
-- The frontend also sends `client` as a free-text name (no
-- dropdown linked to clients) while the DB had a NOT NULL FK
-- `client_id`. We keep the FK column (nullable now) and add a
-- plain-text `client` column for the frontend payload.
--
-- Safe to re-run. `contrats` is empty — no data migration.
-- ─────────────────────────────────────────────────────────────

BEGIN;

-- ─── Rename columns to match frontend ──────────────────────
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='contrats' AND column_name='reference') THEN
    ALTER TABLE public.contrats RENAME COLUMN reference TO numero;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='contrats' AND column_name='total_convenu') THEN
    ALTER TABLE public.contrats RENAME COLUMN total_convenu TO montant;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='contrats' AND column_name='date_contrat') THEN
    ALTER TABLE public.contrats RENAME COLUMN date_contrat TO date_debut;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='contrats' AND column_name='date_echeance') THEN
    ALTER TABLE public.contrats RENAME COLUMN date_echeance TO date_fin;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='contrats' AND column_name='statut_contrat') THEN
    ALTER TABLE public.contrats RENAME COLUMN statut_contrat TO statut;
  END IF;
END$$;

-- ─── Relax NOT NULLs the frontend doesn't always fill ──────
ALTER TABLE public.contrats ALTER COLUMN client_id  DROP NOT NULL;
ALTER TABLE public.contrats ALTER COLUMN date_debut DROP NOT NULL;

-- ─── Add frontend-side columns ─────────────────────────────
-- Plain-text client name (the form is a free text input, not a FK picker)
ALTER TABLE public.contrats ADD COLUMN IF NOT EXISTS client text;

-- ─── Canonicalize statut CHECK to the frontend values ──────
ALTER TABLE public.contrats DROP CONSTRAINT IF EXISTS contrats_statut_check;
ALTER TABLE public.contrats
  ADD CONSTRAINT contrats_statut_check
  CHECK (statut IN ('brouillon','actif','expire','resilie'));

COMMIT;
