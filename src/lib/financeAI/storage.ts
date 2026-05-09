import type { BankTransaction, Category } from './types'

const KEY = 'gestiq_finance_ai_transactions'

function read(): BankTransaction[] {
  try {
    const raw = localStorage.getItem(KEY)
    if (!raw) return []
    const arr = JSON.parse(raw)
    return Array.isArray(arr) ? arr : []
  } catch { return [] }
}

function write(list: BankTransaction[]) {
  try { localStorage.setItem(KEY, JSON.stringify(list)) } catch { /* quota */ }
}

export const transactionsStore = {
  list(): BankTransaction[] {
    return read().sort((a, b) => b.date.localeCompare(a.date))
  },
  addMany(items: BankTransaction[]) {
    const existing = read()
    // dedupe on (date|label|amount) — same statement re-uploaded should not double up
    const seen = new Set(existing.map(t => `${t.date}|${t.label}|${t.amount}`))
    const fresh = items.filter(t => !seen.has(`${t.date}|${t.label}|${t.amount}`))
    write([...existing, ...fresh])
    return fresh.length
  },
  updateCategory(id: string, category: Category) {
    const list = read().map(t => t.id === id ? { ...t, category, manual_override: true, ai_confidence: 1 } : t)
    write(list)
  },
  remove(id: string) {
    write(read().filter(t => t.id !== id))
  },
  clear() {
    write([])
  },
  bySource(): { source: string; count: number; total: number }[] {
    const map = new Map<string, { count: number; total: number }>()
    for (const t of read()) {
      const key = t.source_pdf || 'manuel'
      const cur = map.get(key) ?? { count: 0, total: 0 }
      cur.count++
      cur.total += t.amount
      map.set(key, cur)
    }
    return Array.from(map.entries()).map(([source, v]) => ({ source, ...v }))
  },
}
