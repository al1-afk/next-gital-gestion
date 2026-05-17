-- ================================================================
--  GestiQ — Migration 029 : Table projets (Gestion des projets)
--  Date : 2026-05-17
--
--  Permet la gestion CRUD des projets internes ou liés à un client.
--  Un client peut avoir plusieurs projets (1-N).
--  La suppression d'un client ne supprime pas ses projets : le lien
--  est mis à NULL (ON DELETE SET NULL) pour conserver l'historique.
--
--  Conformité ARCHITECTURE_TENANT.md :
--    - tenant_id NOT NULL FK CASCADE
--    - RLS forcé + 4 policies
--    - Trigger prevent_tenant_id_change + updated_at
--    - GRANT à gestiq_api
-- ================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.projets (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,

  -- Lien client (optionnel : projet interne possible)
  client_id       uuid        REFERENCES public.clients(id) ON DELETE SET NULL,

  -- Identité du projet
  nom             text        NOT NULL,
  description     text,

  -- Statut & priorité
  statut          text        NOT NULL DEFAULT 'planifie'
                              CHECK (statut IN ('planifie','en_cours','en_pause','termine','annule')),
  priorite        text        NOT NULL DEFAULT 'normale'
                              CHECK (priorite IN ('basse','normale','haute','urgente')),

  -- Planification
  date_debut         date,
  date_fin_prevue    date,
  date_fin_reelle    date,

  -- Budget & coûts (MAD)
  budget          numeric(12,2) DEFAULT 0,
  cout_reel       numeric(12,2) DEFAULT 0,

  -- Avancement (0 à 100 %)
  progression     integer     NOT NULL DEFAULT 0
                              CHECK (progression BETWEEN 0 AND 100),

  -- Encadrement
  responsable     text,
  notes           text,

  created_at      timestamptz NOT NULL DEFAULT NOW(),
  updated_at      timestamptz NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_projets_dates CHECK (
    date_fin_prevue IS NULL OR date_debut IS NULL OR date_fin_prevue >= date_debut
  )
);

CREATE INDEX IF NOT EXISTS idx_projets_tenant          ON public.projets (tenant_id);
CREATE INDEX IF NOT EXISTS idx_projets_tenant_client   ON public.projets (tenant_id, client_id);
CREATE INDEX IF NOT EXISTS idx_projets_tenant_statut   ON public.projets (tenant_id, statut);
CREATE INDEX IF NOT EXISTS idx_projets_tenant_created  ON public.projets (tenant_id, created_at DESC);

-- Triggers
DROP TRIGGER IF EXISTS trg_projets_updated_at ON public.projets;
CREATE TRIGGER trg_projets_updated_at BEFORE UPDATE ON public.projets
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_lock_tenant_projets ON public.projets;
CREATE TRIGGER trg_lock_tenant_projets BEFORE UPDATE OF tenant_id ON public.projets
  FOR EACH ROW EXECUTE FUNCTION public.prevent_tenant_id_change();

-- RLS
ALTER TABLE public.projets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projets FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rls_select_projets ON public.projets;
DROP POLICY IF EXISTS rls_insert_projets ON public.projets;
DROP POLICY IF EXISTS rls_update_projets ON public.projets;
DROP POLICY IF EXISTS rls_delete_projets ON public.projets;

CREATE POLICY rls_select_projets ON public.projets FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY rls_insert_projets ON public.projets FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_update_projets ON public.projets FOR UPDATE USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_delete_projets ON public.projets FOR DELETE USING (tenant_id = current_tenant_id());

-- GRANT au rôle API
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'gestiq_api') THEN
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.projets TO gestiq_api;
  END IF;
END $$;

COMMIT;
