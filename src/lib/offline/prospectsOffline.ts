import { prospectsApi } from '@/lib/api'
import { offlineDB, newOfflineId, isOfflineId, type CachedProspect } from './db'
import { enqueue } from './syncQueue'
import type { Prospect } from '@/hooks/useProspects'

/* ─────────────────────────────────────────────────────────────────
   Offline-aware prospects API.

   Reads  — try network, fall back to IndexedDB.  Successful reads are
            cached so subsequent offline loads are instant.
   Writes — if online, hit the server and mirror the result locally.
            If offline, write to IndexedDB with a temp id and push a
            task to the sync queue for later replay.
───────────────────────────────────────────────────────────────── */

const isOnline = () => typeof navigator === 'undefined' || navigator.onLine

function toProspect(row: CachedProspect): Prospect {
  const { _dirty: _d, _deleted: _del, _updatedAt: _u, ...rest } = row
  return rest as Prospect
}

async function cacheList(rows: Prospect[]) {
  const now = Date.now()
  await offlineDB.transaction('rw', offlineDB.prospects, async () => {
    // Keep offline-only rows that haven't synced yet; overwrite the rest.
    const localDirty = await offlineDB.prospects
      .where('_dirty').equals(1).toArray()
    await offlineDB.prospects.clear()
    await offlineDB.prospects.bulkPut(
      rows.map(r => ({ ...r, _dirty: 0, _deleted: 0, _updatedAt: now })),
    )
    if (localDirty.length) await offlineDB.prospects.bulkPut(localDirty)
  })
}

export const prospectsOffline = {
  async list(params?: { orderBy?: string; order?: 'asc' | 'desc' }): Promise<Prospect[]> {
    if (isOnline()) {
      try {
        const rows = await prospectsApi.list(params) as Prospect[]
        await cacheList(rows)
        return rows
      } catch {
        /* fall through to cache */
      }
    }
    const cached = await offlineDB.prospects
      .filter(r => r._deleted !== 1)
      .toArray()
    const sorted = cached.sort((a, b) =>
      (b.created_at ?? '').localeCompare(a.created_at ?? ''),
    )
    return sorted.map(toProspect)
  },

  async create(data: Omit<Prospect, 'id' | 'created_at'>): Promise<Prospect> {
    if (isOnline()) {
      try {
        const created = await prospectsApi.create(data) as Prospect
        await offlineDB.prospects.put({
          ...created, _dirty: 0, _deleted: 0, _updatedAt: Date.now(),
        })
        return created
      } catch {
        /* fall through to offline path */
      }
    }
    const tempId = newOfflineId()
    const row: CachedProspect = {
      id:         tempId,
      created_at: new Date().toISOString(),
      ...data,
      _dirty:     1,
      _deleted:   0,
      _updatedAt: Date.now(),
    } as CachedProspect
    await offlineDB.prospects.put(row)
    await enqueue('prospects', 'create', tempId, data)
    return toProspect(row)
  },

  async update(id: string, data: Partial<Prospect>): Promise<Prospect> {
    const existing = await offlineDB.prospects.get(id)
    const merged: CachedProspect = {
      ...(existing as CachedProspect),
      ...data,
      id,
      _dirty: 1,
      _updatedAt: Date.now(),
    }
    await offlineDB.prospects.put(merged)

    // If the record itself is still offline-only, fold this update into
    // the pending create payload instead of queuing a separate update.
    if (isOfflineId(id)) {
      const pendingCreate = await offlineDB.sync_queue
        .where({ table: 'prospects', recordId: id, op: 'create' }).first()
      if (pendingCreate?.id != null) {
        await offlineDB.sync_queue.update(pendingCreate.id, {
          payload: { ...(pendingCreate.payload as object), ...data },
        })
        return toProspect(merged)
      }
    }

    if (isOnline() && !isOfflineId(id)) {
      try {
        const updated = await prospectsApi.update(id, data) as Prospect
        await offlineDB.prospects.put({
          ...updated, _dirty: 0, _deleted: 0, _updatedAt: Date.now(),
        })
        return updated
      } catch {
        /* fall through — queue for later */
      }
    }
    await enqueue('prospects', 'update', id, data)
    return toProspect(merged)
  },

  async remove(id: string): Promise<{ success: boolean }> {
    // Offline-only record that never reached the server — just drop it
    // and any pending queue items that still point to it.
    if (isOfflineId(id)) {
      await offlineDB.prospects.where('id').equals(id).delete()
      const queued = await offlineDB.sync_queue
        .where('recordId').equals(id).toArray()
      for (const q of queued) if (q.id != null) await offlineDB.sync_queue.delete(q.id)
      return { success: true }
    }

    await offlineDB.prospects.update(id, { _deleted: 1, _dirty: 1, _updatedAt: Date.now() })

    if (isOnline()) {
      try {
        await prospectsApi.remove(id)
        await offlineDB.prospects.where('id').equals(id).delete()
        return { success: true }
      } catch {
        /* fall through */
      }
    }
    await enqueue('prospects', 'delete', id)
    return { success: true }
  },
}
