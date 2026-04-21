-- ================================================================
--  GestiQ — Migration 007: Live DB Retrofit
--  Date: 2026-04-19
--
--  The audit of the live database revealed:
--    - 54 public tables, most NOT covered by migrations 001-006
--    - Zero business tables have tenant_id (multi-tenant isolation
--      is effectively absent — only subscriptions has working RLS)
--    - RLS is enabled on 32 tables with 0 policies → default deny
--      means every API query returns 0 rows
--    - Exactly 1 tenant exists → backfill is unambiguous
--
--  This migration retrofits tenant_id + RLS on every business table
--  in the live schema, using the sole existing tenant for backfill.
--  Idempotent. Safe to re-run. Fully transactional.
--
--  STRICT RULES respected:
--    - No DROP TABLE, no row deletion
--    - No policy removal (only additions / replacements)
--    - All changes wrapped in a single BEGIN…COMMIT
--    - Aborts cleanly if more than one tenant exists (ambiguous backfill)
-- ================================================================

BEGIN;

-- ── 0. Determine the backfill tenant ───────────────────────────
DO $$
DECLARE
  tenant_count INT;
BEGIN
  SELECT COUNT(*) INTO tenant_count FROM tenants;
  IF tenant_count = 0 THEN
    RAISE EXCEPTION 'ABORT: no tenants exist — insert a tenant first';
  ELSIF tenant_count > 1 THEN
    RAISE EXCEPTION 'ABORT: % tenants exist — backfill is ambiguous, handle manually', tenant_count;
  END IF;
END $$;

-- Cache the tenant_id in a session variable (local to this transaction).
DO $$
DECLARE the_tenant UUID;
BEGIN
  SELECT id INTO the_tenant FROM tenants LIMIT 1;
  PERFORM set_config('app.backfill_tenant', the_tenant::text, true);
END $$;

-- ── 1. Canonical helpers ───────────────────────────────────────
CREATE OR REPLACE FUNCTION current_tenant_id() RETURNS UUID
LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.current_tenant', true), '')::UUID
$$;

COMMENT ON FUNCTION current_tenant_id() IS
  'Reads tenant UUID from session variable app.current_tenant set by server/db/pool.ts.';

CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := NOW(); RETURN NEW; END;
$$;

CREATE OR REPLACE FUNCTION prevent_tenant_id_change() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.tenant_id IS DISTINCT FROM OLD.tenant_id THEN
    RAISE EXCEPTION 'tenant_id is immutable (table=%, id=%)', TG_TABLE_NAME, OLD.id
      USING ERRCODE = 'integrity_constraint_violation';
  END IF;
  RETURN NEW;
END;
$$;

-- ── 2. Define which tables are tenant-scoped ───────────────────
-- Excluded: infrastructure and global tables.
CREATE OR REPLACE FUNCTION _gestiq_infrastructure_tables() RETURNS TEXT[]
LANGUAGE sql IMMUTABLE AS $$
  SELECT ARRAY[
    'tenants', 'users', 'tenant_users',
    'login_attempts', 'refresh_tokens'
  ]::TEXT[]
$$;

-- Returns every public table that should have tenant_id + RLS.
CREATE OR REPLACE FUNCTION _gestiq_business_tables() RETURNS SETOF TEXT
LANGUAGE sql STABLE AS $$
  SELECT tablename
  FROM   pg_tables
  WHERE  schemaname = 'public'
    AND  tablename NOT LIKE 'pg_%'
    AND  tablename NOT LIKE '_gestiq%'
    AND  tablename <> ALL(_gestiq_infrastructure_tables())
  ORDER  BY tablename
$$;

-- ── 3. Add tenant_id + backfill + NOT NULL + FK + index ────────
DO $$
DECLARE
  tbl         TEXT;
  the_tenant  UUID := current_setting('app.backfill_tenant')::UUID;
  rows_null   INT;
BEGIN
  FOR tbl IN SELECT _gestiq_business_tables() LOOP
    -- add column if missing
    EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS tenant_id UUID', tbl);

    -- backfill any NULL rows to the sole tenant
    EXECUTE format('UPDATE %I SET tenant_id = $1 WHERE tenant_id IS NULL', tbl)
      USING the_tenant;

    -- now NOT NULL (idempotent: ALTER SET NOT NULL is a no-op if already)
    EXECUTE format('SELECT COUNT(*) FROM %I WHERE tenant_id IS NULL', tbl) INTO rows_null;
    IF rows_null = 0 THEN
      EXECUTE format('ALTER TABLE %I ALTER COLUMN tenant_id SET NOT NULL', tbl);
    END IF;

    -- FK to tenants with named constraint (idempotent)
    IF NOT EXISTS (
      SELECT 1 FROM pg_constraint
      WHERE conname = tbl || '_tenant_fk' AND contype = 'f'
    ) THEN
      EXECUTE format(
        'ALTER TABLE %I ADD CONSTRAINT %I
           FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE',
        tbl, tbl || '_tenant_fk');
    END IF;

    -- tenant_id index
    EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_tenant ON %I (tenant_id)', tbl, tbl);
  END LOOP;
END $$;

-- ── 4. Enable + FORCE RLS, create 4 canonical policies ─────────
DO $$
DECLARE tbl TEXT;
BEGIN
  FOR tbl IN SELECT _gestiq_business_tables() LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', tbl);
    EXECUTE format('ALTER TABLE %I FORCE  ROW LEVEL SECURITY', tbl);

    -- SELECT policy
    EXECUTE format('DROP POLICY IF EXISTS rls_select_%I ON %I', tbl, tbl);
    EXECUTE format(
      'CREATE POLICY rls_select_%I ON %I FOR SELECT
         USING (tenant_id = current_tenant_id())', tbl, tbl);

    -- INSERT policy
    EXECUTE format('DROP POLICY IF EXISTS rls_insert_%I ON %I', tbl, tbl);
    EXECUTE format(
      'CREATE POLICY rls_insert_%I ON %I FOR INSERT
         WITH CHECK (tenant_id = current_tenant_id())', tbl, tbl);

    -- UPDATE policy
    EXECUTE format('DROP POLICY IF EXISTS rls_update_%I ON %I', tbl, tbl);
    EXECUTE format(
      'CREATE POLICY rls_update_%I ON %I FOR UPDATE
         USING (tenant_id = current_tenant_id())
         WITH CHECK (tenant_id = current_tenant_id())', tbl, tbl);

    -- DELETE policy
    EXECUTE format('DROP POLICY IF EXISTS rls_delete_%I ON %I', tbl, tbl);
    EXECUTE format(
      'CREATE POLICY rls_delete_%I ON %I FOR DELETE
         USING (tenant_id = current_tenant_id())', tbl, tbl);
  END LOOP;
END $$;

-- ── 5. tenants / tenant_users policies (not in the loop) ───────
ALTER TABLE tenants      ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenant_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenant_users FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tenants_public_read ON tenants;
CREATE POLICY tenants_public_read ON tenants
  FOR SELECT USING (is_active = TRUE);

DROP POLICY IF EXISTS tenants_self_write ON tenants;
CREATE POLICY tenants_self_write ON tenants
  FOR UPDATE USING (id = current_tenant_id())
  WITH CHECK  (id = current_tenant_id());

DROP POLICY IF EXISTS tu_read_self_tenant ON tenant_users;
CREATE POLICY tu_read_self_tenant ON tenant_users
  FOR SELECT USING (tenant_id = current_tenant_id());

DROP POLICY IF EXISTS tu_write_self_tenant ON tenant_users;
CREATE POLICY tu_write_self_tenant ON tenant_users
  FOR ALL USING (tenant_id = current_tenant_id())
  WITH CHECK  (tenant_id = current_tenant_id());

-- ── 6. Immutability triggers ───────────────────────────────────
DO $$
DECLARE tbl TEXT;
BEGIN
  FOR tbl IN SELECT _gestiq_business_tables() LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS trg_lock_tenant_%I ON %I;
       CREATE TRIGGER trg_lock_tenant_%I
         BEFORE UPDATE OF tenant_id ON %I
         FOR EACH ROW EXECUTE FUNCTION prevent_tenant_id_change()',
      tbl, tbl, tbl, tbl);
  END LOOP;
END $$;

-- ── 7. updated_at triggers ─────────────────────────────────────
DO $$
DECLARE tbl TEXT;
BEGIN
  FOR tbl IN
    SELECT c.table_name
    FROM   information_schema.columns c
    WHERE  c.table_schema = 'public'
      AND  c.column_name = 'updated_at'
      AND NOT EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgname = 'trg_' || c.table_name || '_updated_at'
          AND tgrelid = (c.table_schema || '.' || c.table_name)::regclass
      )
  LOOP
    EXECUTE format(
      'CREATE TRIGGER trg_%I_updated_at
         BEFORE UPDATE ON %I
         FOR EACH ROW EXECUTE FUNCTION set_updated_at()',
      tbl, tbl);
  END LOOP;
END $$;

-- ── 8. Final sanity checks — abort if unsafe ───────────────────
DO $$
DECLARE
  tbl         TEXT;
  nulls       INT;
  no_rls_cnt  INT;
  no_pol_cnt  INT;
BEGIN
  FOR tbl IN SELECT _gestiq_business_tables() LOOP
    EXECUTE format('SELECT COUNT(*) FROM %I WHERE tenant_id IS NULL', tbl) INTO nulls;
    IF nulls > 0 THEN
      RAISE EXCEPTION 'ABORT: % row(s) in % still have NULL tenant_id', nulls, tbl;
    END IF;
  END LOOP;

  SELECT COUNT(*) INTO no_rls_cnt
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname='public'
    AND c.relkind='r'
    AND c.relname IN (SELECT _gestiq_business_tables())
    AND (NOT c.relrowsecurity OR NOT c.relforcerowsecurity);
  IF no_rls_cnt > 0 THEN
    RAISE EXCEPTION 'ABORT: % business table(s) missing ENABLE or FORCE RLS', no_rls_cnt;
  END IF;

  SELECT COUNT(*) INTO no_pol_cnt
  FROM (SELECT _gestiq_business_tables() AS t) x
  WHERE (SELECT COUNT(*) FROM pg_policies
         WHERE schemaname='public' AND tablename = x.t) < 4;
  IF no_pol_cnt > 0 THEN
    RAISE EXCEPTION 'ABORT: % business table(s) have fewer than 4 RLS policies', no_pol_cnt;
  END IF;
END $$;

-- ── 9. Refresh planner stats ───────────────────────────────────
ANALYZE;

COMMIT;

-- ================================================================
--  POST-COMMIT VERIFICATION QUERIES
-- ================================================================
-- 1) Every business table has tenant_id NOT NULL + RLS + 4 policies.
-- SELECT tablename,
--        (SELECT is_nullable FROM information_schema.columns
--         WHERE table_schema='public' AND table_name=t AND column_name='tenant_id') AS tenant_nullable,
--        (SELECT relrowsecurity FROM pg_class c
--         JOIN pg_namespace n ON n.oid=c.relnamespace
--         WHERE n.nspname='public' AND c.relname=t) AS rls_on,
--        (SELECT COUNT(*) FROM pg_policies WHERE schemaname='public' AND tablename=t) AS policies
-- FROM (SELECT _gestiq_business_tables() AS t) x, pg_tables
-- WHERE tablename = t AND schemaname='public'
-- ORDER BY tablename;
--
-- 2) No NULL tenant_id anywhere (run inside app with SET LOCAL):
-- BEGIN;
--   SET LOCAL "app.current_tenant" = '<uuid>';
--   SELECT 'clients' AS t, COUNT(*) FROM clients WHERE tenant_id IS NULL;
-- ROLLBACK;
