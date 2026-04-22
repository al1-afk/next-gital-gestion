import Dexie, { type Table } from 'dexie'

/* ─────────────────────────────────────────────────────────────────
   Offline IndexedDB schema
   - Mirrors the shape of server tables so cached rows can be served
     directly to the UI when offline.
   - `sync_queue` holds pending mutations to replay when back online.
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

  constructor() {
    super('gestiq_offline')
    this.version(1).stores({
      prospects:  'id, statut, created_at, _dirty, _deleted',
      sync_queue: '++id, table, recordId, createdAt',
    })
  }
}

export const offlineDB = new OfflineDB()

/* Visible client-id prefix for records created offline, so we can tell
   them apart from server-issued UUIDs when the sync replays. */
export const OFFLINE_ID_PREFIX = 'off_'
export const isOfflineId = (id: string) => id.startsWith(OFFLINE_ID_PREFIX)
export const newOfflineId = () =>
  `${OFFLINE_ID_PREFIX}${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 8)}`
