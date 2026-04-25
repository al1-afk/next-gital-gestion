import Dexie, { type Table } from 'dexie'
import { currentTenantIdForCache } from '../authToken'

/* ─────────────────────────────────────────────────────────────────
   Offline IndexedDB schema
   - Mirrors the shape of server tables so cached rows can be served
     directly to the UI when offline.
   - `sync_queue` holds pending mutations to replay when back online.

   ⚠️ Multi-tenancy note: the Dexie database name is derived from the
   JWT's tenant_id (see `tenantScopedDbName`). Two users on the same
   browser end up in two separate IndexedDB databases, so User A's
   cached prospects cannot be served to User B — even if the network
   is offline at the moment of the read. On logout, all known tenant
   databases are cleared by `purgeClientSession()` in lib/session.ts.
───────────────────────────────────────────────────────────────── */

export type SyncOp = 'create' | 'update' | 'delete'

export interface SyncQueueItem {
  id?:         number
  table:       string
  op:          SyncOp
  recordId:    string
  payload?:    unknown
  createdAt:   number
  attempts:    number
  lastError?:  string
}

export interface CachedProspect {
  id:             string
  created_at:     string
  nom:            string
  email:          string | null
  telephone:      string | null
  entreprise:     string | null
  statut:         string
  valeur_estimee: number | null
  source:         string | null
  notes:          string | null
  responsable:    string | null
  date_contact:   string | null
  date_relance:   string | null
  _dirty?:        0 | 1
  _deleted?:      0 | 1
  _updatedAt:     number
}

class OfflineDB extends Dexie {
  prospects!:   Table<CachedProspect, string>
  sync_queue!:  Table<SyncQueueItem, number>

  constructor(dbName: string) {
    super(dbName)
    this.version(1).stores({
      prospects:  'id, statut, created_at, _dirty, _deleted',
      sync_queue: '++id, table, recordId, createdAt',
    })
  }
}

const DB_PREFIX = 'gestiq_offline_'

export function tenantScopedDbName(): string {
  return `${DB_PREFIX}${currentTenantIdForCache()}`
}

/* ── Dynamic per-tenant singleton ─────────────────────────────────
   `offlineDB` is a Proxy that re-targets the underlying Dexie handle
   whenever the tenant changes, without forcing every caller to
   re-construct the DB on login/logout. */
let currentDb: OfflineDB | null = null
let currentKey: string = ''

function resolveDb(): OfflineDB {
  const name = tenantScopedDbName()
  if (!currentDb || currentKey !== name) {
    if (currentDb) currentDb.close()
    currentDb = new OfflineDB(name)
    currentKey = name
  }
  return currentDb
}

export const offlineDB = new Proxy({} as OfflineDB, {
  get(_t, prop: string | symbol) {
    const db = resolveDb()
    const val = (db as any)[prop]
    return typeof val === 'function' ? val.bind(db) : val
  },
}) as OfflineDB

/** Deletes every tenant-scoped IndexedDB database known to the
 *  browser. Called by `purgeClientSession()` on logout so a second
 *  user on the same machine starts with an empty cache. */
export async function deleteAllTenantDatabases(): Promise<void> {
  try {
    const listFn = (indexedDB as any).databases as
      (() => Promise<Array<{ name?: string }>>) | undefined
    if (typeof listFn !== 'function') return
    const dbs = await listFn.call(indexedDB)
    await Promise.all(
      dbs
        .filter(d => d.name?.startsWith(DB_PREFIX))
        .map(d => new Promise<void>(resolve => {
          const req = indexedDB.deleteDatabase(d.name!)
          req.onsuccess = req.onerror = req.onblocked = () => resolve()
        })),
    )
    currentDb?.close()
    currentDb = null
    currentKey = ''
  } catch {
    /* Firefox < 126 exposes no indexedDB.databases() — fall back to
       closing the current handle; the per-tenant key already prevents
       cross-user reads. */
    currentDb?.close()
    currentDb = null
    currentKey = ''
  }
}

/* Visible client-id prefix for records created offline, so we can tell
   them apart from server-issued UUIDs when the sync replays. */
export const OFFLINE_ID_PREFIX = 'off_'
export const isOfflineId = (id: string) => id.startsWith(OFFLINE_ID_PREFIX)
export const newOfflineId = () =>
  `${OFFLINE_ID_PREFIX}${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 8)}`
