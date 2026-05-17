-- ================================================================
--  GestiQ — Migration 028 : Collaboration SOP (partage + formation)
--  Date : 2026-05-17
--
--  Ajoute deux tables au module SOP :
--    1. sop_shares — partage d'une SOP avec un membre de l'équipe
--       (lecture / commentaire / édition) ou lien public.
--    2. sop_training_progress — suivi par utilisateur des étapes
--       complétées (mode formation).
--
--  Les images sont stockées en base64 directement dans le JSONB
--  `sops.blocks` (block type 'image') — pas de table dédiée.
--
--  Conformité ARCHITECTURE_TENANT.md :
--    - tenant_id NOT NULL FK CASCADE
--    - RLS forcé + 4 policies par table
--    - Triggers prevent_tenant_id_change + updated_at
--    - GRANT à gestiq_api et gestiq_app
-- ================================================================

BEGIN;

-- ─── 1. sop_shares ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.sop_shares (
  id                  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id           uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  sop_id              uuid        NOT NULL REFERENCES public.sops(id)    ON DELETE CASCADE,
  shared_by           uuid        REFERENCES public.users(id) ON DELETE SET NULL,
  shared_with         uuid        REFERENCES public.users(id) ON DELETE CASCADE,
  -- NULL si lien public
  access_level        text        NOT NULL DEFAULT 'read'
                                   CHECK (access_level IN ('read','comment','edit')),
  public_link_token   text        UNIQUE,
  is_active           boolean     NOT NULL DEFAULT true,
  expires_at          timestamptz,
  created_at          timestamptz NOT NULL DEFAULT NOW(),
  updated_at          timestamptz NOT NULL DEFAULT NOW(),

  -- Une SOP ne peut être partagée qu'une seule fois avec un membre donné
  CONSTRAINT uq_sop_share_user UNIQUE (sop_id, shared_with)
);

CREATE INDEX IF NOT EXISTS idx_sop_shares_tenant       ON public.sop_shares (tenant_id);
CREATE INDEX IF NOT EXISTS idx_sop_shares_sop          ON public.sop_shares (sop_id);
CREATE INDEX IF NOT EXISTS idx_sop_shares_shared_with  ON public.sop_shares (shared_with) WHERE shared_with IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_sop_shares_public_token ON public.sop_shares (public_link_token) WHERE public_link_token IS NOT NULL;

DROP TRIGGER IF EXISTS trg_sop_shares_updated_at ON public.sop_shares;
CREATE TRIGGER trg_sop_shares_updated_at BEFORE UPDATE ON public.sop_shares
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_lock_tenant_sop_shares ON public.sop_shares;
CREATE TRIGGER trg_lock_tenant_sop_shares BEFORE UPDATE OF tenant_id ON public.sop_shares
  FOR EACH ROW EXECUTE FUNCTION public.prevent_tenant_id_change();

ALTER TABLE public.sop_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sop_shares FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rls_select_sop_shares ON public.sop_shares;
DROP POLICY IF EXISTS rls_insert_sop_shares ON public.sop_shares;
DROP POLICY IF EXISTS rls_update_sop_shares ON public.sop_shares;
DROP POLICY IF EXISTS rls_delete_sop_shares ON public.sop_shares;

CREATE POLICY rls_select_sop_shares ON public.sop_shares FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY rls_insert_sop_shares ON public.sop_shares FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_update_sop_shares ON public.sop_shares FOR UPDATE USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_delete_sop_shares ON public.sop_shares FOR DELETE USING (tenant_id = current_tenant_id());

-- ─── 2. sop_training_progress ────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.sop_training_progress (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id       uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  sop_id          uuid        NOT NULL REFERENCES public.sops(id)    ON DELETE CASCADE,
  user_id         uuid        NOT NULL REFERENCES public.users(id)   ON DELETE CASCADE,
  -- index du bloc 'steps' dans sops.blocks (0-based) — pour identifier l'étape
  block_index     int         NOT NULL,
  -- index de l'item à l'intérieur du bloc steps (0-based)
  step_index      int         NOT NULL,
  is_completed    boolean     NOT NULL DEFAULT true,
  completed_at    timestamptz NOT NULL DEFAULT NOW(),
  completed_by    uuid        REFERENCES public.users(id) ON DELETE SET NULL,
  note            text,
  created_at      timestamptz NOT NULL DEFAULT NOW(),
  updated_at      timestamptz NOT NULL DEFAULT NOW(),

  CONSTRAINT uq_training UNIQUE (sop_id, user_id, block_index, step_index)
);

CREATE INDEX IF NOT EXISTS idx_sop_training_tenant ON public.sop_training_progress (tenant_id);
CREATE INDEX IF NOT EXISTS idx_sop_training_user   ON public.sop_training_progress (user_id, sop_id);
CREATE INDEX IF NOT EXISTS idx_sop_training_sop    ON public.sop_training_progress (sop_id);

DROP TRIGGER IF EXISTS trg_sop_training_updated_at ON public.sop_training_progress;
CREATE TRIGGER trg_sop_training_updated_at BEFORE UPDATE ON public.sop_training_progress
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_lock_tenant_sop_training ON public.sop_training_progress;
CREATE TRIGGER trg_lock_tenant_sop_training BEFORE UPDATE OF tenant_id ON public.sop_training_progress
  FOR EACH ROW EXECUTE FUNCTION public.prevent_tenant_id_change();

ALTER TABLE public.sop_training_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sop_training_progress FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rls_select_sop_training ON public.sop_training_progress;
DROP POLICY IF EXISTS rls_insert_sop_training ON public.sop_training_progress;
DROP POLICY IF EXISTS rls_update_sop_training ON public.sop_training_progress;
DROP POLICY IF EXISTS rls_delete_sop_training ON public.sop_training_progress;

CREATE POLICY rls_select_sop_training ON public.sop_training_progress FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY rls_insert_sop_training ON public.sop_training_progress FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_update_sop_training ON public.sop_training_progress FOR UPDATE USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_delete_sop_training ON public.sop_training_progress FOR DELETE USING (tenant_id = current_tenant_id());

-- ─── GRANT aux rôles applicatifs ─────────────────────────────────
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'gestiq_api') THEN
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.sop_shares             TO gestiq_api;
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.sop_training_progress  TO gestiq_api;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'gestiq_app') THEN
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.sop_shares             TO gestiq_app;
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.sop_training_progress  TO gestiq_app;
  END IF;
END $$;

COMMIT;
