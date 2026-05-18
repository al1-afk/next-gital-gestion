-- ════════════════════════════════════════════════════════════════════
--  GestiQ — Migration 046 : Système de gestion d'équipe complet
--  Date : 2026-05-17
--
--  Étend team_members + crée 3 tables :
--    - team_member_sop_access  : accès SOPs par catégorie
--    - team_member_tasks       : tâches assignées (workspace-scoped)
--    - team_member_activity    : journal d'activité
--
--  Conformité ARCHITECTURE_TENANT.md :
--    - tenant_id NOT NULL FK CASCADE sur tables tenant-scoped
--    - RLS + 4 policies par table
--    - Trigger prevent_tenant_id_change + updated_at
--    - GRANT à gestiq_api
--
--  Idempotent : safe à re-runner.
-- ════════════════════════════════════════════════════════════════════

BEGIN;

-- ────────────────────────────────────────────────────────────────────
-- 1) EXTENSIONS team_members (ne PAS modifier les colonnes existantes)
-- ────────────────────────────────────────────────────────────────────
ALTER TABLE public.team_members
  ADD COLUMN IF NOT EXISTS user_id                uuid REFERENCES public.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS member_type            text DEFAULT 'employee',
  ADD COLUMN IF NOT EXISTS job_title              text,
  ADD COLUMN IF NOT EXISTS avatar_url             text,
  ADD COLUMN IF NOT EXISTS invitation_token       text,
  ADD COLUMN IF NOT EXISTS invitation_sent_at     timestamptz,
  ADD COLUMN IF NOT EXISTS invitation_accepted_at timestamptz,
  ADD COLUMN IF NOT EXISTS invitation_expires_at  timestamptz,
  ADD COLUMN IF NOT EXISTS account_status         text DEFAULT 'invited',
  ADD COLUMN IF NOT EXISTS last_login_at          timestamptz,
  ADD COLUMN IF NOT EXISTS created_by             uuid REFERENCES public.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS updated_at             timestamptz DEFAULT NOW();

-- Drop/recreate CHECK constraints souples
ALTER TABLE public.team_members DROP CONSTRAINT IF EXISTS team_members_member_type_check;
ALTER TABLE public.team_members
  ADD CONSTRAINT team_members_member_type_check
  CHECK (member_type IN ('employee','trainer','freelance'));

ALTER TABLE public.team_members DROP CONSTRAINT IF EXISTS team_members_account_status_check;
ALTER TABLE public.team_members
  ADD CONSTRAINT team_members_account_status_check
  CHECK (account_status IN ('invited','active','suspended','archived'));

-- Unique invitation token (partiel — seulement quand non-null)
CREATE UNIQUE INDEX IF NOT EXISTS idx_team_members_invitation_token
  ON public.team_members (invitation_token) WHERE invitation_token IS NOT NULL;

-- Index user_id pour join rapide depuis auth
CREATE INDEX IF NOT EXISTS idx_team_members_user_id
  ON public.team_members (user_id) WHERE user_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_team_members_account_status
  ON public.team_members (tenant_id, account_status);

-- Trigger updated_at
DROP TRIGGER IF EXISTS trg_team_members_updated_at ON public.team_members;
CREATE TRIGGER trg_team_members_updated_at BEFORE UPDATE ON public.team_members
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


-- ────────────────────────────────────────────────────────────────────
-- 2) TABLE team_member_sop_access
-- ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.team_member_sop_access (
  id                uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  team_member_id    uuid        NOT NULL REFERENCES public.team_members(id) ON DELETE CASCADE,
  sop_category      text        NOT NULL,
  access_level      text        NOT NULL DEFAULT 'read'
                                CHECK (access_level IN ('read','complete','edit')),
  granted_at        timestamptz NOT NULL DEFAULT NOW(),
  granted_by        uuid        REFERENCES public.users(id) ON DELETE SET NULL,
  created_at        timestamptz NOT NULL DEFAULT NOW(),
  updated_at        timestamptz NOT NULL DEFAULT NOW(),
  UNIQUE (team_member_id, sop_category)
);

CREATE INDEX IF NOT EXISTS idx_sop_access_tenant   ON public.team_member_sop_access (tenant_id);
CREATE INDEX IF NOT EXISTS idx_sop_access_member   ON public.team_member_sop_access (team_member_id);
CREATE INDEX IF NOT EXISTS idx_sop_access_category ON public.team_member_sop_access (tenant_id, sop_category);

DROP TRIGGER IF EXISTS trg_sop_access_updated_at ON public.team_member_sop_access;
CREATE TRIGGER trg_sop_access_updated_at BEFORE UPDATE ON public.team_member_sop_access
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_sop_access_lock_tenant ON public.team_member_sop_access;
CREATE TRIGGER trg_sop_access_lock_tenant BEFORE UPDATE OF tenant_id ON public.team_member_sop_access
  FOR EACH ROW EXECUTE FUNCTION public.prevent_tenant_id_change();

ALTER TABLE public.team_member_sop_access ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_member_sop_access FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rls_select_sop_access ON public.team_member_sop_access;
DROP POLICY IF EXISTS rls_insert_sop_access ON public.team_member_sop_access;
DROP POLICY IF EXISTS rls_update_sop_access ON public.team_member_sop_access;
DROP POLICY IF EXISTS rls_delete_sop_access ON public.team_member_sop_access;

CREATE POLICY rls_select_sop_access ON public.team_member_sop_access FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY rls_insert_sop_access ON public.team_member_sop_access FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_update_sop_access ON public.team_member_sop_access FOR UPDATE USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_delete_sop_access ON public.team_member_sop_access FOR DELETE USING (tenant_id = current_tenant_id());


-- ────────────────────────────────────────────────────────────────────
-- 3) TABLE team_member_tasks
-- ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.team_member_tasks (
  id                uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  team_member_id    uuid        NOT NULL REFERENCES public.team_members(id) ON DELETE CASCADE,

  title             text        NOT NULL,
  description       text,
  priority          text        NOT NULL DEFAULT 'normal'
                                CHECK (priority IN ('low','normal','high','urgent')),
  status            text        NOT NULL DEFAULT 'todo'
                                CHECK (status IN ('todo','in_progress','done','cancelled')),
  due_date          date,
  project_id        uuid        REFERENCES public.projets(id) ON DELETE SET NULL,

  created_by        uuid        REFERENCES public.users(id) ON DELETE SET NULL,
  created_at        timestamptz NOT NULL DEFAULT NOW(),
  updated_at        timestamptz NOT NULL DEFAULT NOW(),
  completed_at      timestamptz
);

CREATE INDEX IF NOT EXISTS idx_team_tasks_tenant   ON public.team_member_tasks (tenant_id);
CREATE INDEX IF NOT EXISTS idx_team_tasks_member   ON public.team_member_tasks (team_member_id);
CREATE INDEX IF NOT EXISTS idx_team_tasks_status   ON public.team_member_tasks (tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_team_tasks_due      ON public.team_member_tasks (tenant_id, due_date) WHERE due_date IS NOT NULL;

DROP TRIGGER IF EXISTS trg_team_tasks_updated_at ON public.team_member_tasks;
CREATE TRIGGER trg_team_tasks_updated_at BEFORE UPDATE ON public.team_member_tasks
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_team_tasks_lock_tenant ON public.team_member_tasks;
CREATE TRIGGER trg_team_tasks_lock_tenant BEFORE UPDATE OF tenant_id ON public.team_member_tasks
  FOR EACH ROW EXECUTE FUNCTION public.prevent_tenant_id_change();

ALTER TABLE public.team_member_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_member_tasks FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rls_select_team_tasks ON public.team_member_tasks;
DROP POLICY IF EXISTS rls_insert_team_tasks ON public.team_member_tasks;
DROP POLICY IF EXISTS rls_update_team_tasks ON public.team_member_tasks;
DROP POLICY IF EXISTS rls_delete_team_tasks ON public.team_member_tasks;

CREATE POLICY rls_select_team_tasks ON public.team_member_tasks FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY rls_insert_team_tasks ON public.team_member_tasks FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_update_team_tasks ON public.team_member_tasks FOR UPDATE USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_delete_team_tasks ON public.team_member_tasks FOR DELETE USING (tenant_id = current_tenant_id());


-- ────────────────────────────────────────────────────────────────────
-- 4) TABLE team_member_activity
-- ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.team_member_activity (
  id                uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id         uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  team_member_id    uuid        NOT NULL REFERENCES public.team_members(id) ON DELETE CASCADE,

  action_type       text        NOT NULL,
  action_details    jsonb       NOT NULL DEFAULT '{}'::jsonb,

  ip_address        inet,
  user_agent        text,

  created_at        timestamptz NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_team_activity_tenant ON public.team_member_activity (tenant_id);
CREATE INDEX IF NOT EXISTS idx_team_activity_member ON public.team_member_activity (team_member_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_team_activity_action ON public.team_member_activity (tenant_id, action_type);

DROP TRIGGER IF EXISTS trg_team_activity_lock_tenant ON public.team_member_activity;
CREATE TRIGGER trg_team_activity_lock_tenant BEFORE UPDATE OF tenant_id ON public.team_member_activity
  FOR EACH ROW EXECUTE FUNCTION public.prevent_tenant_id_change();

ALTER TABLE public.team_member_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_member_activity FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rls_select_team_activity ON public.team_member_activity;
DROP POLICY IF EXISTS rls_insert_team_activity ON public.team_member_activity;
DROP POLICY IF EXISTS rls_update_team_activity ON public.team_member_activity;
DROP POLICY IF EXISTS rls_delete_team_activity ON public.team_member_activity;

CREATE POLICY rls_select_team_activity ON public.team_member_activity FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY rls_insert_team_activity ON public.team_member_activity FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_update_team_activity ON public.team_member_activity FOR UPDATE USING (tenant_id = current_tenant_id()) WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_delete_team_activity ON public.team_member_activity FOR DELETE USING (tenant_id = current_tenant_id());


-- ────────────────────────────────────────────────────────────────────
-- 5) GRANTS au rôle API
-- ────────────────────────────────────────────────────────────────────
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'gestiq_api') THEN
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.team_member_sop_access TO gestiq_api;
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.team_member_tasks      TO gestiq_api;
    GRANT SELECT, INSERT, UPDATE, DELETE ON public.team_member_activity   TO gestiq_api;
  END IF;
END $$;

COMMIT;
