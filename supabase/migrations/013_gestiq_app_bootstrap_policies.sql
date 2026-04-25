-- ================================================================
--  GestiQ — Migration 013: Auth-bootstrap RLS policies for gestiq_app
--  Date: 2026-04-24
--
--  Context
--  -------
--  The API connects as the non-superuser role `gestiq_app`, while the
--  existing service-read policies on `tenants` and `tenant_users`
--  reference only `gestiq_api` (the admin/migration role).
--
--  Auth bootstrap queries (login, refresh, /me, register) run via the
--  plain `query()` helper — no `app.current_tenant` is set yet, so
--  the tenant-scoped policies (`*_self_tenant`) filter the rows out
--  and login returns `403 Accès refusé` even for valid credentials.
--
--  Fix
--  ---
--  Grant `gestiq_app` the same unrestricted SELECT/INSERT on the two
--  meta tables, scoped to the bootstrap case (no current_tenant set).
--  Tenant-scoped reads/writes keep going through the existing
--  `*_self_tenant` policies, so cross-tenant isolation is preserved.
--
--  Idempotent. Safe to re-run.
-- ================================================================

BEGIN;

DROP POLICY IF EXISTS tu_app_service_read   ON public.tenant_users;
DROP POLICY IF EXISTS tu_app_service_insert ON public.tenant_users;
DROP POLICY IF EXISTS tenants_app_service_read   ON public.tenants;
DROP POLICY IF EXISTS tenants_app_service_insert ON public.tenants;

CREATE POLICY tu_app_service_read ON public.tenant_users
  FOR SELECT TO gestiq_app
  USING (
    current_setting('app.current_tenant', true) IS NULL
    OR current_setting('app.current_tenant', true) = ''
  );

CREATE POLICY tu_app_service_insert ON public.tenant_users
  FOR INSERT TO gestiq_app
  WITH CHECK (
    current_setting('app.current_tenant', true) IS NULL
    OR current_setting('app.current_tenant', true) = ''
  );

CREATE POLICY tenants_app_service_read ON public.tenants
  FOR SELECT TO gestiq_app
  USING (
    current_setting('app.current_tenant', true) IS NULL
    OR current_setting('app.current_tenant', true) = ''
  );

CREATE POLICY tenants_app_service_insert ON public.tenants
  FOR INSERT TO gestiq_app
  WITH CHECK (
    current_setting('app.current_tenant', true) IS NULL
    OR current_setting('app.current_tenant', true) = ''
  );

COMMIT;
