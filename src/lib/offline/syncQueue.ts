import { offlineDB, isOfflineId, type SyncOp, type SyncQueueItem } from './db'
import { prospectsApi } from '@/lib/api'

/* ─────────────────────────────────────────────────────────────────
   Sync queue — replays offline mutations once connectivity returns.

   - enqueue()       — called when a mutation happens while offline
   - flushQueue()    — iterates pending items and sends them to the
                       server; remaps offline ids to server-issued ids
                       across any later queue items that reference them.
───────────────────────────────────────────────────────────────── */

const MAX_ATTEMPTS = 5

export async function enqueue(
  table: string,
  op: SyncOp,
  recordId: string,
  payload?: unknown,
): Promise<void> {
  await offlineDB.sync_queue.add({
    table, op, recordId, payload,
    createdAt: Date.now(),
    attempts: 0,
  })
}

export async function pendingCount(): Promise<number> {
  return offlineDB.sync_queue.count()
}

/* Rewrite subsequent queue items that still reference a temp offline id
   after the server has assigned a real one. */
async function remapOfflineId(oldId: string, newId: string) {
  const items = await offlineDB.sync_queue
    .where('recordId').equals(oldId).toArray()
  for (const it of items) {
    if (it.id != null) {
      await offlineDB.sync_queue.update(it.id, { recordId: newId })
    }
  }
}

type Flusher = (item: SyncQueueItem) => Promise<{ newId?: string } | void>

/* Table-specific adapters. Keep this narrow for now; extend per table
   as offline support expands. */
const flushers: Record<string, Flusher> = {
  async prospects(item) {
    if (item.op === 'create') {
      const created = await prospectsApi.create(item.payload as any) as any
      if (created?.id && created.id !== item.recordId) {
        await offlineDB.prospects.where('id').equals(item.recordId).delete()
        await offlineDB.prospects.put({ ...(created as any), _dirty: 0, _deleted: 0, _updatedAt: Date.now() })
        return { newId: created.id }
      }
    } else if (item.op === 'update') {
      if (isOfflineId(item.recordId)) {
        throw new Error('Cannot update a record with an unresolved offline id')
      }
      await prospectsApi.update(item.recordId, item.payload as any)
      await offlineDB.prospects.update(item.recordId, { _dirty: 0, _updatedAt: Date.now() })
    } else if (item.op === 'delete') {
      if (!isOfflineId(item.recordId)) {
        await prospectsApi.remove(item.recordId)
      }
      await offlineDB.prospects.where('id').equals(item.recordId).delete()
    }
  },
}

let _flushing = false

export async function flushQueue(): Promise<{ flushed: number; failed: number }> {
  if (_flushing) return { flushed: 0, failed: 0 }
  _flushing = true
  let flushed = 0
  let failed = 0
  try {
    const items = await offlineDB.sync_queue.orderBy('createdAt').toArray()
    for (const item of items) {
      const flusher = flushers[item.table]
      if (!flusher) continue
      try {
        const res = await flusher(item)
        if (res?.newId) await remapOfflineId(item.recordId, res.newId)
        if (item.id != null) await offlineDB.sync_queue.delete(item.id)
        flushed++
      } catch (e: any) {
        failed++
        const attempts = (item.attempts ?? 0) + 1
        if (item.id != null) {
          if (attempts >= MAX_ATTEMPTS) {
            await offlineDB.sync_queue.delete(item.id)
          } else {
            await offlineDB.sync_queue.update(item.id, {
              attempts,
              lastError: e?.message ?? String(e),
            })
          }
        }
        break
      }
    }
  } finally {
    _flushing = false
  }
  return { flushed, failed }
}
