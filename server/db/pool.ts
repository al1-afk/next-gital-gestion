import { Pool, PoolClient, types } from 'pg'
import dotenv from 'dotenv'
dotenv.config({ path: '.env.local' })

types.setTypeParser(1700, (val) => val === null ? null : parseFloat(val))
types.setTypeParser(20,   (val) => val === null ? null : parseInt(val, 10))

export const pool = new Pool({
  host:     process.env.PG_HOST     || 'localhost',
  port:     Number(process.env.PG_PORT) || 5432,
  database: process.env.PG_DATABASE || 'gestiq',
  user:     process.env.PG_USER     || 'postgres',
  password: process.env.PG_PASSWORD || '',
  max:      20,
  idleTimeoutMillis:       30_000,
  connectionTimeoutMillis: 2_000,
})

pool.on('error', (err) => {
  console.error('PostgreSQL pool error:', err.message)
})

/* ── Simple queries (no RLS context needed) ───────────────────── */
export async function query<T = any>(sql: string, params?: any[]): Promise<T[]> {
  const { rows } = await pool.query(sql, params)
  return rows
}

export async function queryOne<T = any>(sql: string, params?: any[]): Promise<T | null> {
  const { rows } = await pool.query(sql, params)
  return rows[0] ?? null
}

/* ── Tenant-scoped query: sets app.current_tenant for RLS ────────
   Uses a dedicated connection from the pool so the SET is scoped
   to this transaction only and never leaks to other requests.
─────────────────────────────────────────────────────────────── */
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

export async function tenantQuery<T = any>(
  tenantId: string,
  sql: string,
  params?: any[],
): Promise<T[]> {
  if (!UUID_RE.test(tenantId)) throw new Error('Invalid tenantId')

  const client: PoolClient = await pool.connect()
  try {
    await client.query('BEGIN')
    /* SET LOCAL does not accept $1 — UUID is validated above */
    await client.query(`SET LOCAL "app.current_tenant" = '${tenantId}'`)
    const { rows } = await client.query(sql, params)
    await client.query('COMMIT')
    return rows
  } catch (err) {
    await client.query('ROLLBACK')
    throw err
  } finally {
    client.release()
  }
}

export async function tenantQueryOne<T = any>(
  tenantId: string,
  sql: string,
  params?: any[],
): Promise<T | null> {
  const rows = await tenantQuery<T>(tenantId, sql, params)
  return rows[0] ?? null
}
