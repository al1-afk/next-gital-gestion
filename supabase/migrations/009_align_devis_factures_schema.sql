-- ─────────────────────────────────────────────────────────────
-- 009_align_devis_factures_schema.sql
-- Aligns the live devis/factures tables with what the frontend
-- actually sends (useDevis.ts / useFactures.ts). The live DB
-- still had the pre-retrofit column names (reference, date,
-- validite, tva_rate, status) and narrow enum statuses. The
-- frontend sends (numero, date_emission, date_expiration/
-- date_echeance, tva, statut) and expects broader statut
-- values, so every INSERT was failing with "column does not
-- exist" — which is why "Créer le devis" did nothing.
--
-- Strategy:
--   • Rename columns in place.
--   • Convert statut columns from ENUM → TEXT + CHECK (same
--     pattern used by 008_add_missing_tables.sql). This avoids
--     the "ALTER TYPE ADD VALUE cannot run in a transaction
--     block" limitation and lets us freely extend the allowed
--     values later.
--   • Add the missing denormalized columns (client_nom,
--     client_email, notes, lignes).
--
-- Safe to re-run: every step is IF [NOT] EXISTS / conditional.
-- Both tables are currently empty (verified), so no data
-- migration is needed.
-- ─────────────────────────────────────────────────────────────

BEGIN;

-- ─── devis ──────────────────────────────────────────────────
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='devis' AND column_name='reference') THEN
    ALTER TABLE public.devis RENAME COLUMN reference TO numero;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='devis' AND column_name='date') THEN
    ALTER TABLE public.devis RENAME COLUMN date TO date_emission;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='devis' AND column_name='validite') THEN
    ALTER TABLE public.devis RENAME COLUMN validite TO date_expiration;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='devis' AND column_name='tva_rate') THEN
    ALTER TABLE public.devis RENAME COLUMN tva_rate TO tva;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='devis' AND column_name='status') THEN
    ALTER TABLE public.devis RENAME COLUMN status TO statut;
  END IF;
END$$;

-- Make date_expiration nullable (frontend may leave it empty)
ALTER TABLE public.devis ALTER COLUMN date_expiration DROP NOT NULL;

-- Convert statut enum → text + CHECK
DO $$
BEGIN
  IF (SELECT data_type FROM information_schema.columns
      WHERE table_schema='public' AND table_name='devis' AND column_name='statut') = 'USER-DEFINED' THEN
    ALTER TABLE public.devis ALTER COLUMN statut DROP DEFAULT;
    ALTER TABLE public.devis ALTER COLUMN statut TYPE text USING statut::text;
    ALTER TABLE public.devis ALTER COLUMN statut SET DEFAULT 'brouillon';
  END IF;
END$$;

ALTER TABLE public.devis DROP CONSTRAINT IF EXISTS devis_statut_check;
ALTER TABLE public.devis
  ADD CONSTRAINT devis_statut_check
  CHECK (statut IN ('brouillon','envoye','accepte','refuse','expire'));

-- Add missing columns
ALTER TABLE public.devis ADD COLUMN IF NOT EXISTS client_nom text;
ALTER TABLE public.devis ADD COLUMN IF NOT EXISTS notes      text;
ALTER TABLE public.devis ADD COLUMN IF NOT EXISTS lignes     jsonb NOT NULL DEFAULT '[]'::jsonb;

-- ─── factures ───────────────────────────────────────────────
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='factures' AND column_name='reference') THEN
    ALTER TABLE public.factures RENAME COLUMN reference TO numero;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='factures' AND column_name='date') THEN
    ALTER TABLE public.factures RENAME COLUMN date TO date_emission;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='factures' AND column_name='echeance') THEN
    ALTER TABLE public.factures RENAME COLUMN echeance TO date_echeance;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='factures' AND column_name='tva_rate') THEN
    ALTER TABLE public.factures RENAME COLUMN tva_rate TO tva;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='factures' AND column_name='status') THEN
    ALTER TABLE public.factures RENAME COLUMN status TO statut;
  END IF;
END$$;

-- Make date_echeance nullable (frontend sends null on duplicate)
ALTER TABLE public.factures ALTER COLUMN date_echeance DROP NOT NULL;

-- Allow client_id to be null (frontend types it as nullable)
ALTER TABLE public.factures ALTER COLUMN client_id DROP NOT NULL;

-- Convert statut enum → text + CHECK
DO $$
BEGIN
  IF (SELECT data_type FROM information_schema.columns
      WHERE table_schema='public' AND table_name='factures' AND column_name='statut') = 'USER-DEFINED' THEN
    ALTER TABLE public.factures ALTER COLUMN statut DROP DEFAULT;
    ALTER TABLE public.factures ALTER COLUMN statut TYPE text USING statut::text;
    ALTER TABLE public.factures ALTER COLUMN statut SET DEFAULT 'brouillon';
  END IF;
END$$;

ALTER TABLE public.factures DROP CONSTRAINT IF EXISTS factures_statut_check;
ALTER TABLE public.factures
  ADD CONSTRAINT factures_statut_check
  CHECK (statut IN ('brouillon','envoyee','impayee','partielle','payee','annulee','refusee'));

-- Add missing columns
ALTER TABLE public.factures ADD COLUMN IF NOT EXISTS client_nom   text;
ALTER TABLE public.factures ADD COLUMN IF NOT EXISTS client_email text;
ALTER TABLE public.factures ADD COLUMN IF NOT EXISTS notes        text;

COMMIT;
