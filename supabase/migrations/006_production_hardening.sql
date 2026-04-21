-- ================================================================
--  GestiQ — Migration 006: Production Hardening
--  Date: 2026-04-19
--
--  Single, idempotent, self-contained migration that consolidates
--  every fix from the audit. Safe to run after 005_audit_fixes.sql
--  (or instead of it). Safe to re-run.
--
--  Baseline assumed: pure PostgreSQL deployment. Tenant isolation
--  driven by `SET LOCAL app.current_tenant = '<uuid>'` performed by
--  server/db/pool.ts before every request.
--
--  STRICT RULES respected:
--    - No DROP TABLE
--    - No data deletion
--    - No RLS removal (policies replaced, never dropped without a
--      replacement in the same transaction)
--    - Every change wrapped in a single BEGIN…COMMIT
--    - All DDL uses IF EXISTS / IF NOT EXISTS / OR REPLACE
--    - Backfills precede NOT NULL constraints
--
--  A matching ROLLBACK block lives at the bottom of the file.
-- ================================================================

BEGIN;

-- ── 0. Preconditions ───────────────────────────────────────────
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename='tenants') THEN
    RAISE EXCEPTION 'tenants table missing — run 001_multi_tenant_schema.sql first';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename='users') THEN
    RAISE EXCEPTION 'users table missing — run 002_users_table.sql first';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename='audit_logs') THEN
    RAISE EXCEPTION 'audit_logs missing — run 003_security_hardening.sql first';
  END IF;
END $$;

-- ── 1. Canonical current_tenant_id() — session variable only ───
-- Any prior definition that reads JWT claims is overwritten here.
CREATE OR REPLACE FUNCTION current_tenant_id() RETURNS UUID
LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.current_tenant', true), '')::UUID
$$;

COMMENT ON FUNCTION current_tenant_id() IS
  'Canonical tenant resolver. Reads ONLY from session variable app.current_tenant set by server/db/pool.ts. Do not change to read JWT claims.';

-- ── 2. Canonical set_updated_at() ──────────────────────────────
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := NOW(); RETURN NEW; END;
$$;

-- ── 3. Canonical prevent_tenant_id_change() ────────────────────
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

-- ── 4. Cross-tenant FK guard ───────────────────────────────────
-- Rejects any INSERT/UPDATE whose FK points to a row in a different
-- tenant. Complements RLS (which protects the row itself, not its
-- relatives).
CREATE OR REPLACE FUNCTION check_child_tenant_match() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  fk_col        TEXT := TG_ARGV[0];
  parent_table  TEXT := TG_ARGV[1];
  fk_value      UUID;
  parent_tenant UUID;
BEGIN
  fk_value := NULLIF(row_to_json(NEW)->>fk_col, '')::UUID;
  IF fk_value IS NULL THEN
    RETURN NEW;
  END IF;

  EXECUTE format('SELECT tenant_id FROM %I WHERE id = $1', parent_table)
    INTO parent_tenant USING fk_value;

  IF parent_tenant IS NOT NULL AND parent_tenant <> NEW.tenant_id THEN
    RAISE EXCEPTION
      'cross-tenant reference blocked: %.% -> %.id belongs to another tenant',
      TG_TABLE_NAME, fk_col, parent_table
      USING ERRCODE = 'integrity_constraint_violation';
  END IF;
  RETURN NEW;
END;
$$;

-- ── 5. Tenant-scoped table list (single source of truth) ───────
CREATE OR REPLACE FUNCTION _gestiq_tenant_tables() RETURNS TEXT[]
LANGUAGE sql IMMUTABLE AS $$
  SELECT ARRAY[
    'clients','prospects','devis','factures','paiements','depenses',
    'contrats','produits','fournisseurs','team_members','domaines',
    'hebergements','cheques_recus','cheques_emis','abonnements',
    'client_subscriptions','taches','automation_rules','automation_logs',
    'alerts'
  ]::TEXT[]
$$;

-- ── 6. Enforce tenant_id presence (NOT NULL + FK) ──────────────
-- For every tenant-scoped table that exists, ensure tenant_id is
-- NOT NULL and has FK to tenants(id) ON DELETE CASCADE. Skip if the
-- table is missing entirely (the list is a superset of the schema).
DO $$
DECLARE
  t         TEXT;
  null_cnt  INT;
BEGIN
  FOREACH t IN ARRAY _gestiq_tenant_tables() LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename=t) THEN
      CONTINUE;
    END IF;

    -- add column if missing
    EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS tenant_id UUID', t);

    -- check for NULLs before enforcing NOT NULL
    EXECUTE format('SELECT COUNT(*) FROM %I WHERE tenant_id IS NULL', t) INTO null_cnt;
    IF null_cnt > 0 THEN
      RAISE WARNING
        '% row(s) in % have NULL tenant_id — skipping NOT NULL enforcement. Backfill manually and re-run.',
        null_cnt, t;
    ELSE
      EXECUTE format('ALTER TABLE %I ALTER COLUMN tenant_id SET NOT NULL', t);
    END IF;

    -- add FK if not present (name is stable so idempotent)
    IF NOT EXISTS (
      SELECT 1 FROM pg_constraint
      WHERE conname = t || '_tenant_fk' AND contype = 'f'
    ) THEN
      EXECUTE format(
        'ALTER TABLE %I ADD CONSTRAINT %I
           FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE',
        t, t || '_tenant_fk'
      );
    END IF;
  END LOOP;
END $$;

-- ── 7. Enable + FORCE RLS on every tenant table ────────────────
DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY _gestiq_tenant_tables() LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename=t) THEN
      CONTINUE;
    END IF;
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('ALTER TABLE %I FORCE  ROW LEVEL SECURITY', t);
  END LOOP;

  -- audit_logs + tenant_users also get RLS (but different policy set)
  EXECUTE 'ALTER TABLE audit_logs   ENABLE ROW LEVEL SECURITY';
  EXECUTE 'ALTER TABLE audit_logs   FORCE  ROW LEVEL SECURITY';
  EXECUTE 'ALTER TABLE tenant_users ENABLE ROW LEVEL SECURITY';
  EXECUTE 'ALTER TABLE tenant_users FORCE  ROW LEVEL SECURITY';
  EXECUTE 'ALTER TABLE tenants      ENABLE ROW LEVEL SECURITY';
END $$;

-- ── 8. Canonical RLS policies (replace any legacy policies) ────
-- Replacement is done one table at a time, with the new policy
-- created before the old one is dropped so there is never a window
-- where the table is unprotected.
DO $$
DECLARE
  t       TEXT;
  old_pol TEXT;
BEGIN
  FOREACH t IN ARRAY _gestiq_tenant_tables() LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename=t) THEN
      CONTINUE;
    END IF;

    -- Create new policies first (idempotent via DROP IF EXISTS of same name).
    EXECUTE format('DROP POLICY IF EXISTS rls_select_%I ON %I', t, t);
    EXECUTE format(
      'CREATE POLICY rls_select_%I ON %I FOR SELECT
         USING (tenant_id = current_tenant_id())', t, t);

    EXECUTE format('DROP POLICY IF EXISTS rls_insert_%I ON %I', t, t);
    EXECUTE format(
      'CREATE POLICY rls_insert_%I ON %I FOR INSERT
         WITH CHECK (tenant_id = current_tenant_id())', t, t);

    EXECUTE format('DROP POLICY IF EXISTS rls_update_%I ON %I', t, t);
    EXECUTE format(
      'CREATE POLICY rls_update_%I ON %I FOR UPDATE
         USING (tenant_id = current_tenant_id())
         WITH CHECK (tenant_id = current_tenant_id())', t, t);

    EXECUTE format('DROP POLICY IF EXISTS rls_delete_%I ON %I', t, t);
    EXECUTE format(
      'CREATE POLICY rls_delete_%I ON %I FOR DELETE
         USING (tenant_id = current_tenant_id())', t, t);

    -- Remove any legacy policies from the archived migrations that used
    -- user_id or auth.uid(). They can only ever deny rows (auth.uid()
    -- is NULL here), so dropping is safe.
    FOR old_pol IN
      SELECT policyname FROM pg_policies
      WHERE schemaname='public' AND tablename=t
        AND policyname NOT IN (
          'rls_select_'||t, 'rls_insert_'||t, 'rls_update_'||t, 'rls_delete_'||t
        )
    LOOP
      EXECUTE format('DROP POLICY %I ON %I', old_pol, t);
    END LOOP;
  END LOOP;
END $$;

-- ── 9. audit_logs — append-only policies ───────────────────────
DROP POLICY IF EXISTS rls_audit_select ON audit_logs;
CREATE POLICY rls_audit_select ON audit_logs FOR SELECT
  USING (tenant_id = current_tenant_id());

DROP POLICY IF EXISTS rls_audit_insert ON audit_logs;
CREATE POLICY rls_audit_insert ON audit_logs FOR INSERT
  WITH CHECK (tenant_id = current_tenant_id());
-- Intentionally NO update/delete policy → immutable.

-- ── 10. tenants / tenant_users policies (pure-Postgres form) ───
DROP POLICY IF EXISTS tenant_public_read   ON tenants;
DROP POLICY IF EXISTS tenant_owner_write   ON tenants;
DROP POLICY IF EXISTS tenants_public_read  ON tenants;
DROP POLICY IF EXISTS tenants_self_write   ON tenants;

CREATE POLICY tenants_public_read ON tenants
  FOR SELECT USING (is_active = TRUE);

CREATE POLICY tenants_self_write ON tenants
  FOR UPDATE USING (id = current_tenant_id())
  WITH CHECK  (id = current_tenant_id());

DROP POLICY IF EXISTS tu_read             ON tenant_users;
DROP POLICY IF EXISTS tu_manage           ON tenant_users;
DROP POLICY IF EXISTS tu_read_self_tenant ON tenant_users;
DROP POLICY IF EXISTS tu_write_self_tenant ON tenant_users;

CREATE POLICY tu_read_self_tenant ON tenant_users
  FOR SELECT USING (tenant_id = current_tenant_id());

CREATE POLICY tu_write_self_tenant ON tenant_users
  FOR ALL USING (tenant_id = current_tenant_id())
  WITH CHECK  (tenant_id = current_tenant_id());

-- ── 11. tenant_id immutability trigger on every tenant table ───
DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY _gestiq_tenant_tables() LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename=t) THEN
      CONTINUE;
    END IF;
    EXECUTE format(
      'DROP TRIGGER IF EXISTS trg_lock_tenant_%I ON %I;
       CREATE TRIGGER trg_lock_tenant_%I
         BEFORE UPDATE OF tenant_id ON %I
         FOR EACH ROW EXECUTE FUNCTION prevent_tenant_id_change()',
      t, t, t, t);
  END LOOP;
END $$;

-- ── 12. Cross-tenant FK triggers ───────────────────────────────
DO $$
DECLARE rec RECORD;
BEGIN
  FOR rec IN SELECT * FROM (VALUES
    ('factures',             'client_id',      'clients'),
    ('factures',             'devis_id',       'devis'),
    ('devis',                'client_id',      'clients'),
    ('paiements',            'facture_id',     'factures'),
    ('contrats',             'client_id',      'clients'),
    ('domaines',             'client_id',      'clients'),
    ('hebergements',         'client_id',      'clients'),
    ('cheques_recus',        'client_id',      'clients'),
    ('cheques_emis',         'fournisseur_id', 'fournisseurs'),
    ('client_subscriptions', 'client_id',      'clients'),
    ('taches',               'client_id',      'clients'),
    ('automation_logs',      'rule_id',        'automation_rules')
  ) AS x(child, fk, parent) LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename=rec.child) THEN
      CONTINUE;
    END IF;
    EXECUTE format(
      'DROP TRIGGER IF EXISTS trg_xtenant_%I_%I ON %I;
       CREATE TRIGGER trg_xtenant_%I_%I
         BEFORE INSERT OR UPDATE OF %I, tenant_id ON %I
         FOR EACH ROW EXECUTE FUNCTION check_child_tenant_match(%L, %L)',
      rec.child, rec.fk, rec.child,
      rec.child, rec.fk,
      rec.fk, rec.child,
      rec.fk, rec.parent);
  END LOOP;
END $$;

-- ── 13. updated_at triggers on every table that has the column ─
DO $$
DECLARE tbl TEXT;
BEGIN
  FOR tbl IN
    SELECT c.table_name
    FROM information_schema.columns c
    WHERE c.table_schema='public' AND c.column_name='updated_at'
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

-- ── 14. Indexes — tenant_id, FKs, hot composites ───────────────
-- tenant_id on every tenant table
DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY _gestiq_tenant_tables() LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename=t) THEN
      CONTINUE;
    END IF;
    EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_tenant ON %I (tenant_id)', t, t);
  END LOOP;
END $$;

-- foreign-key indexes
CREATE INDEX IF NOT EXISTS idx_fk_devis_client            ON devis                (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_factures_client         ON factures             (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_factures_devis          ON factures             (devis_id);
CREATE INDEX IF NOT EXISTS idx_fk_paiements_facture       ON paiements            (facture_id);
CREATE INDEX IF NOT EXISTS idx_fk_contrats_client         ON contrats             (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_domaines_client         ON domaines             (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_hebergements_client     ON hebergements         (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_cheques_recus_client    ON cheques_recus        (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_cheques_emis_fourn      ON cheques_emis         (fournisseur_id);
CREATE INDEX IF NOT EXISTS idx_fk_client_subs_client      ON client_subscriptions (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_taches_client           ON taches               (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_taches_assigned         ON taches               (assigned_to);
CREATE INDEX IF NOT EXISTS idx_fk_auto_logs_rule          ON automation_logs      (rule_id);
CREATE INDEX IF NOT EXISTS idx_fk_tenant_users_invited    ON tenant_users         (invited_by);
CREATE INDEX IF NOT EXISTS idx_fk_tenants_owner           ON tenants              (owner_id);

-- hot composites
CREATE INDEX IF NOT EXISTS idx_factures_tenant_statut     ON factures         (tenant_id, statut);
CREATE INDEX IF NOT EXISTS idx_factures_tenant_echeance   ON factures         (tenant_id, date_echeance)
  WHERE statut IN ('impayee','partielle');
CREATE INDEX IF NOT EXISTS idx_devis_tenant_statut        ON devis            (tenant_id, statut);
CREATE INDEX IF NOT EXISTS idx_prospects_tenant_statut    ON prospects        (tenant_id, statut);
CREATE INDEX IF NOT EXISTS idx_paiements_tenant_date      ON paiements        (tenant_id, date_paiement DESC);
CREATE INDEX IF NOT EXISTS idx_depenses_tenant_date       ON depenses         (tenant_id, date_depense DESC);
CREATE INDEX IF NOT EXISTS idx_client_subs_next_billing   ON client_subscriptions (tenant_id, date_prochaine_facturation)
  WHERE statut = 'actif';
CREATE INDEX IF NOT EXISTS idx_hebergements_tenant_exp    ON hebergements     (tenant_id, date_expiration);
CREATE INDEX IF NOT EXISTS idx_alerts_tenant_unread       ON alerts           (tenant_id, is_read) WHERE is_read = FALSE;
CREATE INDEX IF NOT EXISTS idx_audit_tenant_created       ON audit_logs       (tenant_id, created_at DESC);

-- ── 15. Orphan + legacy detection views (read-only, RLS-bypass) ─
-- These are diagnostic views used by the verification queries below.
-- They are created with SECURITY INVOKER semantics but deliberately
-- return counts/ids only so they leak nothing sensitive.
CREATE OR REPLACE VIEW _gestiq_orphan_report AS
  SELECT 'factures' AS child, COUNT(*)::INT AS orphan_count
  FROM factures f
  WHERE f.client_id IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM clients c
                    WHERE c.id = f.client_id AND c.tenant_id = f.tenant_id)
  UNION ALL
  SELECT 'paiements', COUNT(*)::INT
  FROM paiements p
  WHERE p.facture_id IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM factures fa
                    WHERE fa.id = p.facture_id AND fa.tenant_id = p.tenant_id)
  UNION ALL
  SELECT 'devis', COUNT(*)::INT
  FROM devis d
  WHERE d.client_id IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM clients c
                    WHERE c.id = d.client_id AND c.tenant_id = d.tenant_id)
  UNION ALL
  SELECT 'contrats', COUNT(*)::INT
  FROM contrats ctr
  WHERE ctr.client_id IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM clients c
                    WHERE c.id = ctr.client_id AND c.tenant_id = ctr.tenant_id);

COMMENT ON VIEW _gestiq_orphan_report IS
  'Counts rows whose FK points to a parent in a different tenant (or missing). Inspect; do not auto-clean.';

-- Legacy user_id detection: any tenant table that still has a user_id
-- column is drift from the pure-Postgres schema.
CREATE OR REPLACE VIEW _gestiq_legacy_columns AS
  SELECT table_name, column_name
  FROM information_schema.columns
  WHERE table_schema='public'
    AND column_name = 'user_id'
    AND table_name = ANY(_gestiq_tenant_tables());

-- ── 16. Final sanity checks (abort if unsafe) ──────────────────
DO $$
DECLARE
  t     TEXT;
  nulls INT;
  unprotected INT;
BEGIN
  -- NULL tenant_id in any tenant table → abort.
  FOREACH t IN ARRAY _gestiq_tenant_tables() LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename=t) THEN
      CONTINUE;
    END IF;
    EXECUTE format('SELECT COUNT(*) FROM %I WHERE tenant_id IS NULL', t) INTO nulls;
    IF nulls > 0 THEN
      RAISE EXCEPTION 'ABORT: % row(s) in %.tenant_id are NULL', nulls, t;
    END IF;
  END LOOP;

  -- Any tenant table without RLS enabled → abort.
  SELECT COUNT(*) INTO unprotected
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname='public'
    AND c.relname = ANY(_gestiq_tenant_tables())
    AND c.relkind='r'
    AND NOT c.relrowsecurity;
  IF unprotected > 0 THEN
    RAISE EXCEPTION 'ABORT: % tenant table(s) without RLS', unprotected;
  END IF;
END $$;

-- ── 17. Refresh planner stats ──────────────────────────────────
ANALYZE;

COMMIT;

-- ================================================================
--  VERIFICATION QUERIES (run after commit; read-only)
-- ================================================================

-- 1) Every tenant table has RLS + FORCE RLS on.
-- SELECT c.relname AS table,
--        c.relrowsecurity   AS rls_enabled,
--        c.relforcerowsecurity AS rls_forced
-- FROM   pg_class c
-- JOIN   pg_namespace n ON n.oid = c.relnamespace
-- WHERE  n.nspname='public'
--   AND  c.relname = ANY(_gestiq_tenant_tables())
-- ORDER  BY c.relname;

-- 2) Every tenant table has a tenant_id FK + NOT NULL.
-- SELECT t.table_name,
--        c.is_nullable,
--        EXISTS (
--          SELECT 1 FROM pg_constraint pc
--          WHERE pc.conname = t.table_name || '_tenant_fk'
--        ) AS has_fk
-- FROM   information_schema.tables   t
-- JOIN   information_schema.columns  c
--   ON   c.table_name = t.table_name
--  AND   c.column_name = 'tenant_id'
-- WHERE  t.table_schema='public'
--   AND  t.table_name = ANY(_gestiq_tenant_tables());

-- 3) No NULL tenant_id anywhere (should return 0 rows).
-- SELECT unnest(_gestiq_tenant_tables()) AS table_name;
-- -- then for each table:  SELECT COUNT(*) FROM <table> WHERE tenant_id IS NULL;

-- 4) Orphan / cross-tenant report.
-- SELECT * FROM _gestiq_orphan_report WHERE orphan_count > 0;

-- 5) Legacy user_id drift on tenant tables (should be empty).
-- SELECT * FROM _gestiq_legacy_columns;

-- 6) Policy coverage — every tenant table has 4 canonical policies.
-- SELECT tablename, COUNT(*) AS policy_count
-- FROM   pg_policies
-- WHERE  schemaname='public'
--   AND  tablename = ANY(_gestiq_tenant_tables())
-- GROUP  BY tablename
-- HAVING COUNT(*) < 4;  -- any row returned means incomplete RLS

-- 7) Immutability trigger coverage.
-- SELECT unnest(_gestiq_tenant_tables()) AS t
-- EXCEPT
-- SELECT tgrelid::regclass::text
-- FROM   pg_trigger
-- WHERE  tgname LIKE 'trg_lock_tenant_%';
-- -- any row returned means a table is missing the lock trigger

-- ================================================================
--  MANUAL-INTERVENTION WARNINGS
-- ================================================================
-- (a) If step 6 emitted "NULL tenant_id" warnings, backfill with:
--       UPDATE <table> SET tenant_id = '<uuid>' WHERE tenant_id IS NULL AND <cond>;
--     then re-run this migration to set NOT NULL.
-- (b) If _gestiq_orphan_report returns rows, investigate manually.
--     Safe cleanup pattern (per table, inside its own transaction):
--       BEGIN;
--       -- option A: null-out the FK (keeps history)
--       UPDATE factures f
--          SET client_id = NULL
--        WHERE f.client_id IS NOT NULL
--          AND NOT EXISTS (SELECT 1 FROM clients c
--                          WHERE c.id = f.client_id AND c.tenant_id = f.tenant_id);
--       -- option B: move the parent into the child's tenant (review first!)
--       COMMIT;
-- (c) If _gestiq_legacy_columns returns rows, drop user_id AFTER you
--     have confirmed no application code still reads it:
--       ALTER TABLE <table> DROP COLUMN user_id;
-- (d) src/lib/supabase.ts still declares user_id on every Row type.
--     The schema now uses tenant_id. Update the TypeScript definitions
--     or every Supabase call will return undefined for user_id.
-- (e) Supabase CLI picks up every *.sql file in migrations/ — the two
--     legacy 001_*.sql files were moved to migrations/_archive/.
--     Do not move them back.

-- ================================================================
--  ROLLBACK (manual, reversible)
-- ================================================================
-- BEGIN;
--   -- Policies (drop in reverse of step 8; recreate old ones if needed)
--   DO $r$
--   DECLARE t TEXT;
--   BEGIN
--     FOREACH t IN ARRAY _gestiq_tenant_tables() LOOP
--       EXECUTE format('DROP POLICY IF EXISTS rls_select_%I ON %I', t, t);
--       EXECUTE format('DROP POLICY IF EXISTS rls_insert_%I ON %I', t, t);
--       EXECUTE format('DROP POLICY IF EXISTS rls_update_%I ON %I', t, t);
--       EXECUTE format('DROP POLICY IF EXISTS rls_delete_%I ON %I', t, t);
--     END LOOP;
--   END $r$;
--
--   -- Triggers
--   DO $r$
--   DECLARE t TEXT;
--   BEGIN
--     FOREACH t IN ARRAY _gestiq_tenant_tables() LOOP
--       EXECUTE format('DROP TRIGGER IF EXISTS trg_lock_tenant_%I ON %I', t, t);
--     END LOOP;
--   END $r$;
--
--   -- Cross-tenant FK triggers (enumerate the 12 pairs from step 12)
--   -- DROP TRIGGER IF EXISTS trg_xtenant_factures_client_id ON factures; ...
--
--   -- Views
--   DROP VIEW IF EXISTS _gestiq_orphan_report;
--   DROP VIEW IF EXISTS _gestiq_legacy_columns;
--
--   -- Functions
--   DROP FUNCTION IF EXISTS check_child_tenant_match();
--   DROP FUNCTION IF EXISTS _gestiq_tenant_tables();
-- COMMIT;
