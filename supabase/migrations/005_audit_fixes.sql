-- ================================================================
--  GestiQ — Migration 005: Audit fixes (safe, reversible)
--  Date: 2026-04-19
--
--  Purpose: consolidate schema drift from three conflicting 001_*.sql
--  files, close tenant-isolation gaps, add missing FK indexes, and
--  enforce invariants. Targets the pure-Postgres deployment path used
--  by server/db/pool.ts (session variable app.current_tenant).
--
--  RULES:
--    - Wrapped in a single transaction
--    - No DROP TABLE, no data loss
--    - All DDL uses IF EXISTS / IF NOT EXISTS
--    - RLS policies are only replaced, never removed
--    - Backfill before NOT NULL, never the reverse
--  Rollback notes live next to each block.
-- ================================================================

BEGIN;

-- ── 0. Preconditions ────────────────────────────────────────────
-- Require the pure-Postgres baseline. Abort early if tables missing.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'tenants') THEN
    RAISE EXCEPTION 'tenants table missing — run 001_multi_tenant_schema.sql first';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
    RAISE EXCEPTION 'users table missing — run 002_users_table.sql first';
  END IF;
END $$;

-- ── 1. Canonicalize current_tenant_id() ─────────────────────────
-- Issue: 001_multi_tenant.sql reads from JWT claims, 004 reads from
-- session variable. Production uses session variable (server/db/pool.ts).
-- Fix: redefine with session-variable-only semantics. JWT path is dead.
-- Rollback: restore previous body from 001_multi_tenant.sql.
CREATE OR REPLACE FUNCTION current_tenant_id() RETURNS UUID
LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.current_tenant', true), '')::UUID
$$;

COMMENT ON FUNCTION current_tenant_id() IS
  'Returns tenant UUID from session var app.current_tenant. Set by server/db/pool.ts via SET LOCAL.';

-- ── 2. Add tenant_id where missing ──────────────────────────────
-- personal_tasks exists in TS types but not in pure-Postgres schema.
-- taches is the canonical table. If personal_tasks exists (legacy),
-- add tenant_id + FK so RLS can be applied.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'personal_tasks') THEN
    -- add column if missing
    ALTER TABLE personal_tasks ADD COLUMN IF NOT EXISTS tenant_id UUID;

    -- best-effort backfill from taches by client_id + titre (only if exact match)
    UPDATE personal_tasks pt
       SET tenant_id = t.tenant_id
      FROM taches t
     WHERE pt.tenant_id IS NULL
       AND t.titre = pt.titre
       AND t.client_id IS NOT DISTINCT FROM pt.client_id;

    -- orphans get no backfill; we refuse to GUESS tenant_id.
    -- Report them so an operator can decide.
    IF EXISTS (SELECT 1 FROM personal_tasks WHERE tenant_id IS NULL) THEN
      RAISE NOTICE 'personal_tasks has % rows without tenant_id — inspect manually before enforcing NOT NULL',
        (SELECT COUNT(*) FROM personal_tasks WHERE tenant_id IS NULL);
    ELSE
      ALTER TABLE personal_tasks
        ADD CONSTRAINT personal_tasks_tenant_fk
        FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE;
      ALTER TABLE personal_tasks ALTER COLUMN tenant_id SET NOT NULL;
    END IF;
  END IF;
END $$;

-- ── 3. Missing FK indexes (performance) ─────────────────────────
-- FKs without indexes cause sequential scans on parent deletes and
-- on JOINs. Add concurrently-safe IF NOT EXISTS indexes.
-- Rollback: DROP INDEX ... each idx_fk_*.
CREATE INDEX IF NOT EXISTS idx_fk_devis_client           ON devis            (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_factures_client        ON factures         (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_factures_devis         ON factures         (devis_id);
CREATE INDEX IF NOT EXISTS idx_fk_paiements_facture      ON paiements        (facture_id);
CREATE INDEX IF NOT EXISTS idx_fk_contrats_client        ON contrats         (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_domaines_client        ON domaines         (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_hebergements_client    ON hebergements     (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_cheques_recus_client   ON cheques_recus    (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_cheques_emis_fourn     ON cheques_emis     (fournisseur_id);
CREATE INDEX IF NOT EXISTS idx_fk_client_subs_client     ON client_subscriptions (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_taches_client          ON taches           (client_id);
CREATE INDEX IF NOT EXISTS idx_fk_taches_assigned        ON taches           (assigned_to);
CREATE INDEX IF NOT EXISTS idx_fk_auto_logs_rule         ON automation_logs  (rule_id);
CREATE INDEX IF NOT EXISTS idx_fk_tenant_users_invited   ON tenant_users     (invited_by);
CREATE INDEX IF NOT EXISTS idx_fk_tenants_owner          ON tenants          (owner_id);

-- Composite (tenant_id, hot_column) indexes for common filters.
CREATE INDEX IF NOT EXISTS idx_factures_tenant_statut    ON factures         (tenant_id, statut);
CREATE INDEX IF NOT EXISTS idx_factures_tenant_echeance  ON factures         (tenant_id, date_echeance)
  WHERE statut IN ('impayee','partielle');
CREATE INDEX IF NOT EXISTS idx_devis_tenant_statut       ON devis            (tenant_id, statut);
CREATE INDEX IF NOT EXISTS idx_prospects_tenant_statut   ON prospects        (tenant_id, statut);
CREATE INDEX IF NOT EXISTS idx_paiements_tenant_date     ON paiements        (tenant_id, date_paiement DESC);
CREATE INDEX IF NOT EXISTS idx_depenses_tenant_date      ON depenses         (tenant_id, date_depense DESC);
CREATE INDEX IF NOT EXISTS idx_client_subs_next_billing  ON client_subscriptions (tenant_id, date_prochaine_facturation)
  WHERE statut = 'actif';
CREATE INDEX IF NOT EXISTS idx_hebergements_tenant_exp   ON hebergements     (tenant_id, date_expiration);
CREATE INDEX IF NOT EXISTS idx_audit_tenant_created      ON audit_logs       (tenant_id, created_at DESC);

-- ── 4. Orphan detection (report, do not delete) ─────────────────
-- We do not delete orphans automatically. Operator must review.
-- Query-only: DO block raises NOTICE counts.
DO $$
DECLARE
  orphan_factures     INT;
  orphan_paiements    INT;
  orphan_devis        INT;
  orphan_contrats     INT;
BEGIN
  SELECT COUNT(*) INTO orphan_factures FROM factures f
    WHERE f.client_id IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM clients c WHERE c.id = f.client_id AND c.tenant_id = f.tenant_id);
  SELECT COUNT(*) INTO orphan_paiements FROM paiements p
    WHERE p.facture_id IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM factures f WHERE f.id = p.facture_id AND f.tenant_id = p.tenant_id);
  SELECT COUNT(*) INTO orphan_devis FROM devis d
    WHERE d.client_id IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM clients c WHERE c.id = d.client_id AND c.tenant_id = d.tenant_id);
  SELECT COUNT(*) INTO orphan_contrats FROM contrats ctr
    WHERE ctr.client_id IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM clients c WHERE c.id = ctr.client_id AND c.tenant_id = ctr.tenant_id);

  RAISE NOTICE 'Orphan scan: factures=%, paiements=%, devis=%, contrats=%',
    orphan_factures, orphan_paiements, orphan_devis, orphan_contrats;
END $$;

-- ── 5. Cross-tenant integrity trigger ───────────────────────────
-- Even with RLS, a SECURITY DEFINER function could insert a row
-- whose parent lives in another tenant. Block that at write time.
CREATE OR REPLACE FUNCTION check_child_tenant_match()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  parent_tenant UUID;
BEGIN
  IF TG_ARGV[0] IS NULL OR TG_ARGV[1] IS NULL THEN
    RETURN NEW;
  END IF;

  IF (CASE TG_ARGV[0]
        WHEN 'client_id'     THEN (row_to_json(NEW)->>'client_id')
        WHEN 'facture_id'    THEN (row_to_json(NEW)->>'facture_id')
        WHEN 'devis_id'      THEN (row_to_json(NEW)->>'devis_id')
        WHEN 'fournisseur_id' THEN (row_to_json(NEW)->>'fournisseur_id')
      END) IS NULL THEN
    RETURN NEW;
  END IF;

  EXECUTE format(
    'SELECT tenant_id FROM %I WHERE id = $1',
    TG_ARGV[1]
  )
  INTO parent_tenant
  USING (row_to_json(NEW)->>TG_ARGV[0])::UUID;

  IF parent_tenant IS NOT NULL AND parent_tenant <> NEW.tenant_id THEN
    RAISE EXCEPTION 'cross-tenant reference blocked: %.% -> %',
      TG_TABLE_NAME, TG_ARGV[0], TG_ARGV[1];
  END IF;

  RETURN NEW;
END;
$$;

DO $$
DECLARE
  rec RECORD;
BEGIN
  FOR rec IN SELECT * FROM (VALUES
    ('factures',             'client_id',     'clients'),
    ('factures',             'devis_id',      'devis'),
    ('devis',                'client_id',     'clients'),
    ('paiements',            'facture_id',    'factures'),
    ('contrats',             'client_id',     'clients'),
    ('domaines',             'client_id',     'clients'),
    ('hebergements',         'client_id',     'clients'),
    ('cheques_recus',        'client_id',     'clients'),
    ('cheques_emis',         'fournisseur_id','fournisseurs'),
    ('client_subscriptions', 'client_id',     'clients'),
    ('taches',               'client_id',     'clients')
  ) AS x(child, fk, parent) LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS trg_xtenant_%I_%I ON %I;
       CREATE TRIGGER trg_xtenant_%I_%I
       BEFORE INSERT OR UPDATE OF %I, tenant_id ON %I
       FOR EACH ROW EXECUTE FUNCTION check_child_tenant_match(%L, %L)',
      rec.child, rec.fk, rec.child,
      rec.child, rec.fk,
      rec.fk, rec.child,
      rec.fk, rec.parent
    );
  END LOOP;
END $$;

-- ── 6. Missing updated_at triggers ──────────────────────────────
-- set_updated_at() already exists. Attach it to every table that has
-- an updated_at column but no trigger.
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN
    SELECT c.table_name
    FROM information_schema.columns c
    WHERE c.table_schema = 'public'
      AND c.column_name = 'updated_at'
      AND NOT EXISTS (
        SELECT 1 FROM pg_trigger tr
        WHERE tr.tgname = 'trg_' || c.table_name || '_updated_at'
      )
  LOOP
    EXECUTE format(
      'CREATE TRIGGER trg_%I_updated_at
       BEFORE UPDATE ON %I
       FOR EACH ROW EXECUTE FUNCTION set_updated_at()',
      tbl, tbl
    );
  END LOOP;
END $$;

-- ── 7. tenant_id immutability — extend to all tenant tables ─────
-- 004_rls_and_production.sql applied prevent_tenant_id_change only to
-- 6 tables. Apply to the full set so no table is writable-across-tenant.
DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'clients','prospects','devis','factures','paiements','depenses',
    'contrats','produits','fournisseurs','team_members','domaines',
    'hebergements','cheques_recus','cheques_emis','abonnements',
    'client_subscriptions','taches','automation_rules','automation_logs','alerts'
  ] LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS trg_lock_tenant_%I ON %I;
       CREATE TRIGGER trg_lock_tenant_%I
       BEFORE UPDATE ON %I
       FOR EACH ROW EXECUTE FUNCTION prevent_tenant_id_change()',
      t, t, t, t
    );
  END LOOP;
END $$;

-- ── 8. RLS on tenants / tenant_users (pure-Postgres variant) ────
-- 001_multi_tenant.sql enabled RLS but its policies use auth.uid(),
-- which does not exist in the pure-Postgres deployment. Replace with
-- session-variable equivalents so the tables are not accidentally
-- locked down for the API role.
ALTER TABLE tenants      ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenant_users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tenant_public_read  ON tenants;
DROP POLICY IF EXISTS tenant_owner_write  ON tenants;
DROP POLICY IF EXISTS tu_read             ON tenant_users;
DROP POLICY IF EXISTS tu_manage           ON tenant_users;

-- Slug resolution is needed BEFORE a tenant is selected, so allow
-- unauthenticated read of minimal active-tenant info. Sensitive
-- columns should be filtered at the API layer.
CREATE POLICY tenants_public_read ON tenants
  FOR SELECT USING (is_active = TRUE);

CREATE POLICY tenants_self_write ON tenants
  FOR UPDATE USING (id = current_tenant_id())
  WITH CHECK (id = current_tenant_id());

CREATE POLICY tu_read_self_tenant ON tenant_users
  FOR SELECT USING (tenant_id = current_tenant_id());

CREATE POLICY tu_write_self_tenant ON tenant_users
  FOR ALL USING (tenant_id = current_tenant_id())
  WITH CHECK (tenant_id = current_tenant_id());

-- ── 9. Force RLS even for table owner ───────────────────────────
-- Prevents accidental bypass when a query runs as the table owner.
DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'clients','prospects','devis','factures','paiements','depenses',
    'contrats','produits','fournisseurs','team_members','domaines',
    'hebergements','cheques_recus','cheques_emis','abonnements',
    'client_subscriptions','taches','automation_rules','automation_logs',
    'alerts','audit_logs','tenant_users'
  ] LOOP
    EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', t);
  END LOOP;
END $$;

-- ── 10. Rows without tenant_id (final sanity check) ─────────────
-- Fail the migration if any tenant-scoped table has NULL tenant_id.
-- This catches drift between legacy (user_id) data and the pure-PG schema.
DO $$
DECLARE
  t       TEXT;
  nulls   INT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'clients','prospects','devis','factures','paiements','depenses',
    'contrats','produits','fournisseurs','team_members','domaines',
    'hebergements','cheques_recus','cheques_emis','abonnements',
    'client_subscriptions','taches','automation_rules','automation_logs','alerts'
  ] LOOP
    EXECUTE format('SELECT COUNT(*) FROM %I WHERE tenant_id IS NULL', t) INTO nulls;
    IF nulls > 0 THEN
      RAISE EXCEPTION '% row(s) in % have NULL tenant_id — fix before committing', nulls, t;
    END IF;
  END LOOP;
END $$;

-- ── 11. ANALYZE to refresh planner stats after index creation ───
ANALYZE;

COMMIT;

-- ================================================================
--  ROLLBACK (manual — run inside a transaction)
-- ================================================================
-- BEGIN;
--   -- drop new indexes
--   DROP INDEX IF EXISTS idx_fk_devis_client, idx_fk_factures_client,
--     idx_fk_factures_devis, idx_fk_paiements_facture, idx_fk_contrats_client,
--     idx_fk_domaines_client, idx_fk_hebergements_client, idx_fk_cheques_recus_client,
--     idx_fk_cheques_emis_fourn, idx_fk_client_subs_client, idx_fk_taches_client,
--     idx_fk_taches_assigned, idx_fk_auto_logs_rule, idx_fk_tenant_users_invited,
--     idx_fk_tenants_owner, idx_factures_tenant_statut, idx_factures_tenant_echeance,
--     idx_devis_tenant_statut, idx_prospects_tenant_statut, idx_paiements_tenant_date,
--     idx_depenses_tenant_date, idx_client_subs_next_billing, idx_hebergements_tenant_exp,
--     idx_audit_tenant_created;
--   -- drop cross-tenant triggers (loop of DROP TRIGGER trg_xtenant_*)
--   -- drop tenant-lock triggers added in step 7
--   -- restore old policies on tenants / tenant_users from 001_multi_tenant.sql
--   DROP FUNCTION IF EXISTS check_child_tenant_match() CASCADE;
-- COMMIT;
