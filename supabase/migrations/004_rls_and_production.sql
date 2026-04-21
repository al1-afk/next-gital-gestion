-- ================================================================
--  GestiQ — Production Security: RLS + Immutable Logs + DB Roles
-- ================================================================

-- ── 1. Create limited DB user for the API ───────────────────────
-- Run as superuser once:
-- CREATE ROLE gestiq_api LOGIN PASSWORD 'CHANGE_THIS_STRONG_PASSWORD';
-- GRANT CONNECT ON DATABASE gestiq TO gestiq_api;
-- GRANT USAGE ON SCHEMA public TO gestiq_api;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO gestiq_api;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO gestiq_api;
-- REVOKE ALL ON audit_logs FROM gestiq_api;
-- GRANT INSERT, SELECT ON audit_logs TO gestiq_api;  -- append-only

-- ── 2. Enable RLS on ALL tenant-scoped tables ────────────────────
ALTER TABLE clients              ENABLE ROW LEVEL SECURITY;
ALTER TABLE prospects            ENABLE ROW LEVEL SECURITY;
ALTER TABLE devis                ENABLE ROW LEVEL SECURITY;
ALTER TABLE factures             ENABLE ROW LEVEL SECURITY;
ALTER TABLE paiements            ENABLE ROW LEVEL SECURITY;
ALTER TABLE depenses             ENABLE ROW LEVEL SECURITY;
ALTER TABLE contrats             ENABLE ROW LEVEL SECURITY;
ALTER TABLE produits             ENABLE ROW LEVEL SECURITY;
ALTER TABLE fournisseurs         ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members         ENABLE ROW LEVEL SECURITY;
ALTER TABLE domaines             ENABLE ROW LEVEL SECURITY;
ALTER TABLE hebergements         ENABLE ROW LEVEL SECURITY;
ALTER TABLE cheques_recus        ENABLE ROW LEVEL SECURITY;
ALTER TABLE cheques_emis         ENABLE ROW LEVEL SECURITY;
ALTER TABLE abonnements          ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE taches               ENABLE ROW LEVEL SECURITY;
ALTER TABLE automation_rules     ENABLE ROW LEVEL SECURITY;
ALTER TABLE automation_logs      ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts               ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs           ENABLE ROW LEVEL SECURITY;

-- ── 3. Helper: read current tenant from session variable ─────────
CREATE OR REPLACE FUNCTION current_tenant_id() RETURNS UUID
LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.current_tenant', true), '')::UUID
$$;

-- ── 4. RLS POLICIES — tenant isolation ──────────────────────────
-- Pattern: each table gets SELECT/INSERT/UPDATE/DELETE policies

DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'clients','prospects','devis','factures','paiements','depenses',
    'contrats','produits','fournisseurs','team_members','domaines',
    'hebergements','cheques_recus','cheques_emis','abonnements',
    'client_subscriptions','taches','automation_rules','automation_logs',
    'alerts'
  ] LOOP
    -- DROP existing
    EXECUTE format('DROP POLICY IF EXISTS rls_select_%I ON %I', t, t);
    EXECUTE format('DROP POLICY IF EXISTS rls_insert_%I ON %I', t, t);
    EXECUTE format('DROP POLICY IF EXISTS rls_update_%I ON %I', t, t);
    EXECUTE format('DROP POLICY IF EXISTS rls_delete_%I ON %I', t, t);

    -- SELECT: only own tenant
    EXECUTE format(
      'CREATE POLICY rls_select_%I ON %I FOR SELECT
       USING (tenant_id = current_tenant_id())', t, t
    );
    -- INSERT: force correct tenant_id
    EXECUTE format(
      'CREATE POLICY rls_insert_%I ON %I FOR INSERT
       WITH CHECK (tenant_id = current_tenant_id())', t, t
    );
    -- UPDATE: only own records
    EXECUTE format(
      'CREATE POLICY rls_update_%I ON %I FOR UPDATE
       USING (tenant_id = current_tenant_id())
       WITH CHECK (tenant_id = current_tenant_id())', t, t
    );
    -- DELETE: only own records
    EXECUTE format(
      'CREATE POLICY rls_delete_%I ON %I FOR DELETE
       USING (tenant_id = current_tenant_id())', t, t
    );
  END LOOP;
END $$;

-- ── 5. audit_logs: append-only policy ───────────────────────────
DROP POLICY IF EXISTS rls_audit_select ON audit_logs;
DROP POLICY IF EXISTS rls_audit_insert ON audit_logs;

CREATE POLICY rls_audit_select ON audit_logs FOR SELECT
  USING (tenant_id = current_tenant_id());

CREATE POLICY rls_audit_insert ON audit_logs FOR INSERT
  WITH CHECK (tenant_id = current_tenant_id());

-- NO UPDATE / DELETE policy on audit_logs → nobody can modify

-- ── 6. Immutable audit_logs — revoke at table level ─────────────
REVOKE UPDATE, DELETE, TRUNCATE ON audit_logs FROM PUBLIC;
REVOKE UPDATE, DELETE, TRUNCATE ON audit_logs FROM said;

-- ── 7. Refresh tokens — append-only except revoke column ────────
ALTER TABLE refresh_tokens ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION current_user_id() RETURNS UUID
LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.current_user', true), '')::UUID
$$;

-- ── 8. Enforce: tenant_id cannot be changed after insert ─────────
CREATE OR REPLACE FUNCTION prevent_tenant_id_change()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.tenant_id <> OLD.tenant_id THEN
    RAISE EXCEPTION 'tenant_id cannot be changed after creation';
  END IF;
  RETURN NEW;
END;
$$;

DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'clients','factures','paiements','depenses','devis','contrats'
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

-- ── 9. Login brute-force tracking function ───────────────────────
CREATE OR REPLACE FUNCTION count_failed_logins(p_email TEXT, p_minutes INT DEFAULT 15)
RETURNS INT LANGUAGE sql STABLE AS $$
  SELECT COUNT(*)::INT
  FROM login_attempts
  WHERE email = p_email
    AND success = false
    AND attempted_at > NOW() - (p_minutes || ' minutes')::INTERVAL
$$;
