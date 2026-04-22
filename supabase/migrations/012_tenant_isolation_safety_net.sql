-- ================================================================
--  GestiQ — Migration 012: Tenant isolation safety-net
--  Date: 2026-04-22
--
--  Guarantees that:
--    1. `personal_tasks` exists with tenant_id + FK + RLS + policies
--       (was in the TS types but never retrofitted by 007).
--    2. The `gestiq_api` application role is NOT a superuser and does
--       NOT have BYPASSRLS — otherwise every RLS policy is silently
--       ignored and the entire app becomes cross-tenant readable.
--    3. Every public business table still has:
--         - tenant_id column NOT NULL
--         - FORCE ROW LEVEL SECURITY
--         - ≥ 4 RLS policies (SELECT/INSERT/UPDATE/DELETE)
--       Aborts loudly if any of those invariants drifts.
--
--  Idempotent. Safe to re-run. Fully transactional.
-- ================================================================

BEGIN;

-- ── 0. Sanity: gestiq_api exists, is not super, is not BYPASSRLS ──
DO $$
DECLARE
  r RECORD;
BEGIN
  SELECT rolname, rolsuper, rolbypassrls
    INTO r
    FROM pg_roles
   WHERE rolname = 'gestiq_api';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'ABORT: role "gestiq_api" does not exist — create it before running this migration';
  END IF;
  IF r.rolsuper THEN
    RAISE EXCEPTION 'ABORT: role "gestiq_api" is SUPERUSER — RLS is bypassed. Run: ALTER ROLE gestiq_api NOSUPERUSER;';
  END IF;
  IF r.rolbypassrls THEN
    RAISE EXCEPTION 'ABORT: role "gestiq_api" has BYPASSRLS — RLS is bypassed. Run: ALTER ROLE gestiq_api NOBYPASSRLS;';
  END IF;
END $$;

-- ── 1. personal_tasks — create if missing, retrofit if partial ────
CREATE TABLE IF NOT EXISTS public.personal_tasks (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     uuid        NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  titre         text        NOT NULL,
  description   text,
  statut        text        NOT NULL DEFAULT 'todo'
                              CHECK (statut IN ('todo','en_cours','done')),
  priorite      text        NOT NULL DEFAULT 'important'
                              CHECK (priorite IN ('urgent_important','important','urgent','low')),
  date_echeance date,
  client_id     uuid        REFERENCES public.clients(id) ON DELETE SET NULL,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

-- If table pre-existed without tenant_id, patch it
ALTER TABLE public.personal_tasks
  ADD COLUMN IF NOT EXISTS tenant_id uuid;

-- If any pre-existing rows have NULL tenant_id, we can't silently pick
-- a tenant — abort so the operator handles it manually.
DO $$
DECLARE nulls int;
BEGIN
  SELECT COUNT(*) INTO nulls FROM public.personal_tasks WHERE tenant_id IS NULL;
  IF nulls > 0 THEN
    RAISE EXCEPTION 'ABORT: % row(s) in personal_tasks have NULL tenant_id — assign manually before re-running', nulls;
  END IF;
END $$;

ALTER TABLE public.personal_tasks ALTER COLUMN tenant_id SET NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
     WHERE conname = 'personal_tasks_tenant_fk' AND contype = 'f'
  ) THEN
    ALTER TABLE public.personal_tasks
      ADD CONSTRAINT personal_tasks_tenant_fk
      FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) ON DELETE CASCADE;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_personal_tasks_tenant  ON public.personal_tasks (tenant_id);
CREATE INDEX IF NOT EXISTS idx_personal_tasks_created ON public.personal_tasks (tenant_id, created_at DESC);

-- updated_at + tenant immutability triggers
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_personal_tasks_updated_at') THEN
    CREATE TRIGGER trg_personal_tasks_updated_at
      BEFORE UPDATE ON public.personal_tasks
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_lock_tenant_personal_tasks') THEN
    CREATE TRIGGER trg_lock_tenant_personal_tasks
      BEFORE UPDATE OF tenant_id ON public.personal_tasks
      FOR EACH ROW EXECUTE FUNCTION public.prevent_tenant_id_change();
  END IF;
END $$;

ALTER TABLE public.personal_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.personal_tasks FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS rls_select_personal_tasks ON public.personal_tasks;
DROP POLICY IF EXISTS rls_insert_personal_tasks ON public.personal_tasks;
DROP POLICY IF EXISTS rls_update_personal_tasks ON public.personal_tasks;
DROP POLICY IF EXISTS rls_delete_personal_tasks ON public.personal_tasks;

CREATE POLICY rls_select_personal_tasks ON public.personal_tasks
  FOR SELECT USING (tenant_id = current_tenant_id());
CREATE POLICY rls_insert_personal_tasks ON public.personal_tasks
  FOR INSERT WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_update_personal_tasks ON public.personal_tasks
  FOR UPDATE USING (tenant_id = current_tenant_id())
  WITH CHECK (tenant_id = current_tenant_id());
CREATE POLICY rls_delete_personal_tasks ON public.personal_tasks
  FOR DELETE USING (tenant_id = current_tenant_id());

GRANT SELECT, INSERT, UPDATE, DELETE ON public.personal_tasks TO gestiq_api;

-- ── 2. Global sweep: every business table still has NOT NULL / RLS / 4 policies
DO $$
DECLARE
  tbl         text;
  nulls       int;
  rls_on      boolean;
  rls_forced  boolean;
  pol_count   int;
  nullable    text;
  missing_any int := 0;
BEGIN
  FOR tbl IN SELECT _gestiq_business_tables() LOOP
    -- tenant_id NOT NULL
    SELECT is_nullable INTO nullable
      FROM information_schema.columns
     WHERE table_schema = 'public' AND table_name = tbl AND column_name = 'tenant_id';
    IF nullable IS NULL THEN
      RAISE EXCEPTION 'ABORT: table "%" has no tenant_id column', tbl;
    END IF;
    IF nullable = 'YES' THEN
      RAISE EXCEPTION 'ABORT: tenant_id on "%" is NULLABLE', tbl;
    END IF;

    -- No NULL rows
    EXECUTE format('SELECT COUNT(*) FROM %I WHERE tenant_id IS NULL', tbl) INTO nulls;
    IF nulls > 0 THEN
      RAISE EXCEPTION 'ABORT: % row(s) in % have NULL tenant_id', nulls, tbl;
    END IF;

    -- RLS enabled + forced
    SELECT c.relrowsecurity, c.relforcerowsecurity
      INTO rls_on, rls_forced
      FROM pg_class c
      JOIN pg_namespace n ON n.oid = c.relnamespace
     WHERE n.nspname = 'public' AND c.relname = tbl;
    IF NOT rls_on     THEN RAISE EXCEPTION 'ABORT: RLS not ENABLED on %',  tbl; END IF;
    IF NOT rls_forced THEN RAISE EXCEPTION 'ABORT: RLS not FORCED on %',   tbl; END IF;

    -- ≥ 4 policies
    SELECT COUNT(*) INTO pol_count
      FROM pg_policies
     WHERE schemaname = 'public' AND tablename = tbl;
    IF pol_count < 4 THEN
      RAISE EXCEPTION 'ABORT: table "%" has % RLS policies (< 4)', tbl, pol_count;
    END IF;
  END LOOP;
END $$;

ANALYZE;

COMMIT;

-- ================================================================
--  POST-COMMIT SPOT CHECKS
-- ================================================================
-- SELECT rolname, rolsuper, rolbypassrls FROM pg_roles WHERE rolname='gestiq_api';
-- SELECT tablename, COUNT(*) AS policies
--   FROM pg_policies WHERE schemaname='public'
--   GROUP BY tablename ORDER BY tablename;
