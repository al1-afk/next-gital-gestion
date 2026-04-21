## Archived legacy migrations — DO NOT RUN

The two files in this folder are superseded by `001_multi_tenant_schema.sql`
and conflict with the production schema. They were moved here on 2026-04-19
because re-applying them would:

- **001_multi_tenant.sql** — redefines `current_tenant_id()` to read from JWT
  claims instead of the session variable `app.current_tenant` used by
  `server/db/pool.ts`. Would silently break RLS for every API query.

- **001_saas_upgrade.sql** — creates `automation_rules`, `automation_logs`,
  `alerts`, `client_subscriptions`, `workspace_members` keyed on `user_id`
  (Supabase auth) instead of `tenant_id`. Already replaced by the
  tenant-scoped versions in `001_multi_tenant_schema.sql`.

If you need to reference them for history, read in place. Never move them
back into `../migrations/`.
