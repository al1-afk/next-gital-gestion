import { useEffect, useState } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { flushQueue, pendingCount } from '@/lib/offline/syncQueue'

/* ─────────────────────────────────────────────────────────────────
   Runs flushQueue() on mount, on "online" events, and on a slow
   interval as a safety net. Refreshes TanStack Query caches for any
   table that was touched.
───────────────────────────────────────────────────────────────── */
export function useOfflineSync() {
  const qc = useQueryClient()
  const [pending, setPending] = useState(0)

  useEffect(() => {
    let cancelled = false

    async function refreshPendingCount() {
      const n = await pendingCount()
      if (!cancelled) setPending(n)
    }

    async function run() {
      if (typeof navigator !== 'undefined' && !navigator.onLine) {
        await refreshPendingCount()
        return
      }
      const before = await pendingCount()
      if (before === 0) { await refreshPendingCount(); return }
      const { flushed, failed } = await flushQueue()
      if (flushed > 0) {
        qc.invalidateQueries({ queryKey: ['prospects'] })
        toast.success(`${flushed} modification${flushed > 1 ? 's' : ''} synchronisée${flushed > 1 ? 's' : ''}`)
      }
      if (failed > 0) {
        toast.error('Certaines modifications n\'ont pas pu être synchronisées')
      }
      await refreshPendingCount()
    }

    run()
    const onOnline = () => { run() }
    window.addEventListener('online', onOnline)
    const interval = window.setInterval(run, 60_000)

    return () => {
      cancelled = true
      window.removeEventListener('online', onOnline)
      window.clearInterval(interval)
    }
  }, [qc])

  return { pending }
}
