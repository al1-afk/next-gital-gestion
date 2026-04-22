/* ─────────────────────────────────────────────────────────────────
   Tenant isolation — anti-leak integration test suite.

   Runs against the live dev API: `npm run server` (port 4000) +
   Postgres on PG_HOST/PG_PORT from .env.local. Uses node:test, which
   ships with Node ≥ 18 — no extra framework needed.

   Scenarios covered:
     1. Data isolation         — B sees 0 of A's clients
     2. Cross-tenant GET by id — 404 (not 403, to avoid disclosure)
     3. Cross-tenant UPDATE    — 404, not silent success
     4. Cross-tenant DELETE    — 404, A's row still exists
     5. Forged tenant_id body  — server ignores body, uses JWT
     6. RBAC: viewer can't DELETE
     7. CASCADE delete         — removing tenant A wipes all rows
   Usage:
     npm run server              # terminal 1
     node --import tsx --test tests/tenant-isolation.test.ts
───────────────────────────────────────────────────────────────── */

import test     from 'node:test'
import assert   from 'node:assert/strict'
import { Pool } from 'pg'
import 'dotenv/config'

const API_URL = process.env.TEST_API_URL || 'http://localhost:4000'

const adminPool = new Pool({
  host:     process.env.PG_HOST     || '127.0.0.1',
  port:     Number(process.env.PG_PORT) || 5433,
  database: process.env.PG_DATABASE || 'gestiq',
  user:     process.env.PG_USER     || 'gestiq_api',
  password: process.env.PG_PASSWORD || '',
})

/* ── helpers ───────────────────────────────────────────────────── */

type Token = { token: string; tenantId: string; tenantSlug: string; role?: string }

async function api<T = any>(
  path: string,
  init: RequestInit & { token?: string } = {},
): Promise<{ status: number; body: T }> {
  const { token, headers, ...rest } = init as any
  const res = await fetch(`${API_URL}${path}`, {
    ...rest,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...headers,
    },
  })
  const body = await res.json().catch(() => ({}))
  return { status: res.status, body }
}

function uniq(prefix: string): string {
  return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`
}

async function registerTenant(): Promise<Token> {
  const slug  = uniq('tst')
  const email = `${slug}@example.test`
  const { status, body } = await api<Token>('/api/auth/register', {
    method: 'POST',
    body: JSON.stringify({
      email,
      password:   'Strong-Password-123',
      name:       slug,
      tenantSlug: slug,
      tenantName: slug,
    }),
  })
  assert.equal(status, 201, `register failed: ${JSON.stringify(body)}`)
  return { ...(body as any), tenantSlug: slug }
}

async function addMember(tenantId: string, role: string): Promise<Token> {
  // We don't have a public "create user in existing tenant" API, so we
  // register a new tenant to get a user, then insert a membership row
  // directly via the app DB pool (this is an integration test — the
  // point is to exercise the HTTP boundary, not replicate every flow).
  const { token, tenantId: _t } = await registerTenant()
  const payload = JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString())
  const userId  = payload.userId

  await adminPool.query(
    `INSERT INTO tenant_users (tenant_id, user_id, role, status)
     VALUES ($1, $2, $3, 'active')
     ON CONFLICT (tenant_id, user_id) DO UPDATE SET role=EXCLUDED.role`,
    [tenantId, userId, role],
  )

  // Re-login targeting the new tenant so the JWT carries its tenantId
  const email = payload.email
  const { body: loginBody, status } = await api<Token>('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, password: 'Strong-Password-123', tenantSlug: (await tenantSlugFor(tenantId)) }),
  })
  assert.equal(status, 200, `login failed: ${JSON.stringify(loginBody)}`)
  return loginBody as Token
}

async function tenantSlugFor(tenantId: string): Promise<string> {
  const r = await adminPool.query('SELECT slug FROM tenants WHERE id = $1', [tenantId])
  return r.rows[0].slug
}

async function createClient(token: string, nom: string): Promise<{ id: string }> {
  const { status, body } = await api('/api/clients', {
    method: 'POST',
    token,
    body: JSON.stringify({ nom, ville: 'Casablanca' }),
  })
  assert.equal(status, 201, `createClient failed: ${JSON.stringify(body)}`)
  return body as { id: string }
}

/* ── tests ─────────────────────────────────────────────────────── */

test('1. Isolation basique: B ne voit aucun client de A', async () => {
  const A = await registerTenant()
  const B = await registerTenant()

  await createClient(A.token, 'Alpha-1')
  await createClient(A.token, 'Alpha-2')
  await createClient(A.token, 'Alpha-3')

  const { status, body } = await api<any[]>('/api/clients', { token: B.token })
  assert.equal(status, 200)
  assert.equal(Array.isArray(body), true)
  assert.equal((body as any[]).length, 0, 'B must see zero of A\'s clients')
})

test('2. GET cross-tenant par id retourne 404 (pas 403)', async () => {
  const A = await registerTenant()
  const B = await registerTenant()

  const a1 = await createClient(A.token, 'Alpha-secret')
  const { status } = await api(`/api/clients/${a1.id}`, { token: B.token })
  assert.equal(status, 404)
})

test('3. UPDATE cross-tenant retourne 404 et ne modifie rien', async () => {
  const A = await registerTenant()
  const B = await registerTenant()

  const a1 = await createClient(A.token, 'Alpha-readonly')

  const r = await api(`/api/clients/${a1.id}`, {
    method: 'PATCH',
    token: B.token,
    body: JSON.stringify({ nom: 'HACKED-by-B' }),
  })
  assert.equal(r.status, 404)

  const { body: fresh } = await api<any>(`/api/clients/${a1.id}`, { token: A.token })
  assert.equal((fresh as any).nom, 'Alpha-readonly')
})

test('4. DELETE cross-tenant retourne 404, la ligne reste', async () => {
  const A = await registerTenant()
  const B = await registerTenant()

  const a1 = await createClient(A.token, 'Alpha-undeletable')

  const r = await api(`/api/clients/${a1.id}`, { method: 'DELETE', token: B.token })
  assert.equal(r.status, 404)

  const { status } = await api(`/api/clients/${a1.id}`, { token: A.token })
  assert.equal(status, 200)
})

test('5. Forge de tenant_id dans le body est ignorée', async () => {
  const A = await registerTenant()
  const B = await registerTenant()

  /* B tente d\'insérer dans A en forgeant tenant_id dans le body */
  const { status, body } = await api<any>('/api/clients', {
    method: 'POST',
    token:  B.token,
    body:   JSON.stringify({ nom: 'Forged', tenant_id: A.tenantId }),
  })
  assert.equal(status, 201)
  assert.equal((body as any).tenant_id, B.tenantId, 'server must overwrite body tenant_id with JWT tenantId')

  /* A ne doit pas voir cette ligne */
  const { body: list } = await api<any[]>('/api/clients', { token: A.token })
  assert.equal((list as any[]).find((c: any) => c.nom === 'Forged'), undefined)
})

test('6. RBAC: viewer ne peut pas DELETE', async () => {
  const owner = await registerTenant()
  const c1    = await createClient(owner.token, 'ToDeleteLater')

  const viewer = await addMember(owner.tenantId, 'viewer')
  const r = await api(`/api/clients/${c1.id}`, { method: 'DELETE', token: viewer.token })
  assert.equal(r.status, 403)

  /* et la ligne existe toujours */
  const { status } = await api(`/api/clients/${c1.id}`, { token: owner.token })
  assert.equal(status, 200)
})

test('7. CASCADE: supprimer tenant A efface toutes ses lignes', async () => {
  const A = await registerTenant()
  const B = await registerTenant()

  await createClient(A.token, 'Alpha-x')
  await createClient(A.token, 'Alpha-y')
  const bOne = await createClient(B.token, 'Bravo-z')

  await adminPool.query('DELETE FROM tenants WHERE id = $1', [A.tenantId])

  const { rows: left } = await adminPool.query(
    'SELECT id FROM clients WHERE tenant_id = $1', [A.tenantId],
  )
  assert.equal(left.length, 0, 'A\'s clients must be CASCADE-deleted')

  /* B intact */
  const { status, body } = await api(`/api/clients/${bOne.id}`, { token: B.token })
  assert.equal(status, 200)
  assert.equal((body as any).nom, 'Bravo-z')
})

test('close pool', async () => {
  await adminPool.end()
})
