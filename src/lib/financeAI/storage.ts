import type { BankTransaction, Category, AccountType } from './types'

const KEYS: Record<AccountType, string> = {
  personal: 'gestiq_finance_ai_transactions',
  company:  'gestiq_finance_ai_transactions_company',
}

const ACTIVE_KEY = 'gestiq_finance_ai_active_account'

function read(account: AccountType): BankTransaction[] {
  try {
    const raw = localStorage.getItem(KEYS[account])
    if (!raw) return []
    const arr = JSON.parse(raw)
    return Array.isArray(arr) ? arr : []
  } catch { return [] }
}

function write(account: AccountType, list: BankTransaction[]) {
  try { localStorage.setItem(KEYS[account], JSON.stringify(list)) } catch { /* quota */ }
}

export const transactionsStore = {
  storageKey(account: AccountType): string {
    return KEYS[account]
  },

  getActive(): AccountType {
    const v = localStorage.getItem(ACTIVE_KEY)
    return v === 'company' ? 'company' : 'personal'
  },

  setActive(account: AccountType) {
    try { localStorage.setItem(ACTIVE_KEY, account) } catch { /* ignore */ }
  },

  list(account: AccountType): BankTransaction[] {
    return read(account).sort((a, b) => b.date.localeCompare(a.date))
  },

  addMany(account: AccountType, items: BankTransaction[]): number {
    const existing = read(account)
    const seen = new Set(existing.map(t => `${t.date}|${t.label}|${t.amount}`))
    const fresh = items.filter(t => !seen.has(`${t.date}|${t.label}|${t.amount}`))
    write(account, [...existing, ...fresh])
    return fresh.length
  },

  updateCategory(account: AccountType, id: string, category: Category) {
    const list = read(account).map(t =>
      t.id === id ? { ...t, category, manual_override: true, ai_confidence: 1 } : t
    )
    write(account, list)
  },

  remove(account: AccountType, id: string) {
    write(account, read(account).filter(t => t.id !== id))
  },

  clear(account: AccountType) {
    write(account, [])
  },

  bySource(account: AccountType): { source: string; count: number; total: number }[] {
    const map = new Map<string, { count: number; total: number }>()
    for (const t of read(account)) {
      const key = t.source_pdf || 'manuel'
      const cur = map.get(key) ?? { count: 0, total: 0 }
      cur.count++
      cur.total += t.amount
      map.set(key, cur)
    }
    return Array.from(map.entries()).map(([source, v]) => ({ source, ...v }))
  },

  raw: { read, write },
}
