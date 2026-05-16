-- ================================================================
--  GestiQ — Migration 025 : Table sops (SOPs personnalisés par tenant)
--  Date : 2026-05-16
--
--  Permet la création/édition/suppression de SOPs par les utilisateurs.
--  Les SOPs statiques codés dans src/pages/SOP.tsx restent affichés
--  comme exemples (read-only) ; les SOPs créés via UI sont stockés ici
--  avec CRUD complet.
--
--  Conformité ARCHITECTURE_TENANT.md :
--    - tenant_id NOT NULL FK CASCADE
--    - RLS forcé + 4 policies
--    - Trigger prevent_tenant_id_change + updated_at
--    - GRANT à gestiq_api (et gestiq_app via default privileges)
-- ================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS public.sops (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id    uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  slug         text        NOT NULL,
  title        text        NOT NULL,
  description  text,
  category     text        NOT NULL DEFAULT 'whatsapp',
  tags         jsonb       NOT NULL DEFAULT '[]'::jsonb,
  author       text,
  author_bg    text        NOT NULL DEFAULT 'bg-blue-500',
  read_min     int         NOT NULL DEFAULT 2,
  views        int         NOT NULL DEFAULT 0,
  popular      boolean     NOT NULL DEFAULT false,
  blocks       jsonb       NOT NULL DEFAULT '[]'::jsonb,
  created_at   timestamptz NOT NULL DEFAULT NOW(),
  updated_at   timestamptz NOT NULL DEFAULT NOW(),
  UNIQUE (tenant_id, slug)
);
CREATE INDEX IF NOT EXISTS idx_sops_tenant         ON public.sops (tenant_id);
CREATE INDEX IF NOT EXISTS idx_sops_tenant_category ON public.sops (tenant_id, category);
CREATE INDEX IF NOT EXISTS idx_sops_tenant_created  ON public.sops (tenant_id, created_at DESC);

-- Triggers
DROP TRIGGER IF EXISTS trg_sops_updated_at ON public.sops;
CREATE TRIGGER trg_sops_updated_at BEFORE UPDATE ON public.sops
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_lock_tenant_sops ON public.sops;
CREATE TRIGGER trg_lock_tenant_sops BEFORE UPDATE OF tenant_id ON public.sops
  FOR EACH ROW EXECUTE FUNCTION public.prevent_tenant_id_change();

-- RLS
ALTER TABLE public.sops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sops FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rls_select_sops ON public.sops;
DROP POLICY IF EXISTS rls_insert_sops ON public.sops;
DROP POLICY IF EXISTS rls_update_sops ON public.sops;
DROP POLICY IF EXISTS rls_delete_sops ON public.sops;

CREATE POLICY rls_select_sops ON public.sops FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY rls_insert_sops ON public.sops FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_update_sops ON public.sops FOR UPDATE USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_delete_sops ON public.sops FOR DELETE USING (tenant_id = current_tenant_id());

-- GRANT au rôle API (si existe)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'gestiq_api') THEN
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.sops TO gestiq_api;
  END IF;
END $$;

COMMIT;
