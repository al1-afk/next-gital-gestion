-- ================================================================
--  GestiQ — Migration 027 : Table stagiaires (Gestion des stagiaires)
--  Date : 2026-05-16
--
--  Permet la gestion CRUD des stagiaires accueillis par le tenant.
--  À partir des données saisies, l'app génère 3 documents PDF :
--    1. Attestation d'acceptation de stage
--    2. Convention de stage
--    3. Attestation de stage (fin de stage)
--
--  Conformité ARCHITECTURE_TENANT.md :
--    - tenant_id NOT NULL FK CASCADE
--    - RLS forcé + 4 policies
--    - Trigger prevent_tenant_id_change + updated_at
--    - GRANT à gestiq_api
-- ================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.stagiaires (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,

  -- Identité
  nom_complet     text        NOT NULL,
  genre           text        NOT NULL DEFAULT 'homme'
                              CHECK (genre IN ('homme','femme')),
  cin             text        NOT NULL,
  date_naissance  date,
  lieu_naissance  text,

  -- Coordonnées
  telephone       text        NOT NULL,
  email           text        NOT NULL,
  adresse         text        NOT NULL,

  -- Formation & stage
  etablissement   text        NOT NULL,
  formation       text        NOT NULL DEFAULT 'Marketing digital / Création de site internet',
  departement     text        NOT NULL DEFAULT 'création de sites web et référencement naturel (SEO)',
  date_debut      date        NOT NULL,
  date_fin        date        NOT NULL,
  statut          text        NOT NULL DEFAULT 'accepte'
                              CHECK (statut IN ('accepte','en_cours','termine','annule')),

  notes           text,

  created_at      timestamptz NOT NULL DEFAULT NOW(),
  updated_at      timestamptz NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_stagiaires_dates CHECK (date_fin >= date_debut)
);

CREATE INDEX IF NOT EXISTS idx_stagiaires_tenant          ON public.stagiaires (tenant_id);
CREATE INDEX IF NOT EXISTS idx_stagiaires_tenant_statut   ON public.stagiaires (tenant_id, statut);
CREATE INDEX IF NOT EXISTS idx_stagiaires_tenant_created  ON public.stagiaires (tenant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_stagiaires_tenant_cin      ON public.stagiaires (tenant_id, cin);

-- Triggers
DROP TRIGGER IF EXISTS trg_stagiaires_updated_at ON public.stagiaires;
CREATE TRIGGER trg_stagiaires_updated_at BEFORE UPDATE ON public.stagiaires
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_lock_tenant_stagiaires ON public.stagiaires;
CREATE TRIGGER trg_lock_tenant_stagiaires BEFORE UPDATE OF tenant_id ON public.stagiaires
  FOR EACH ROW EXECUTE FUNCTION public.prevent_tenant_id_change();

-- RLS
ALTER TABLE public.stagiaires ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stagiaires FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rls_select_stagiaires ON public.stagiaires;
DROP POLICY IF EXISTS rls_insert_stagiaires ON public.stagiaires;
DROP POLICY IF EXISTS rls_update_stagiaires ON public.stagiaires;
DROP POLICY IF EXISTS rls_delete_stagiaires ON public.stagiaires;

CREATE POLICY rls_select_stagiaires ON public.stagiaires FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY rls_insert_stagiaires ON public.stagiaires FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_update_stagiaires ON public.stagiaires FOR UPDATE USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_delete_stagiaires ON public.stagiaires FOR DELETE USING (tenant_id = current_tenant_id());

-- GRANT au rôle API
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'gestiq_api') THEN
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.stagiaires TO gestiq_api;
  END IF;
END $$;

COMMIT;
