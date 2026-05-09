import type { BankTransaction, Category } from './types'
import { isIncomeCategory } from './classifier'

export interface KPIs {
  totalIncome: number
  totalExpense: number
  netProfit: number
  cashWithdrawn: number
  freelancesPaid: number
  adSpend: number
  hostingSpend: number
  saasSpend: number
  txCount: number
}

export function computeKPIs(list: BankTransaction[]): KPIs {
  const k: KPIs = {
    totalIncome: 0, totalExpense: 0, netProfit: 0,
    cashWithdrawn: 0, freelancesPaid: 0, adSpend: 0,
    hostingSpend: 0, saasSpend: 0, txCount: list.length,
  }
  for (const t of list) {
    if (t.amount >= 0) k.totalIncome += t.amount
    else k.totalExpense += Math.abs(t.amount)
    if (t.category === 'cash_withdrawal') k.cashWithdrawn += Math.abs(t.amount)
    if (t.category === 'freelance')       k.freelancesPaid += Math.abs(t.amount)
    if (t.category === 'advertising')     k.adSpend        += Math.abs(t.amount)
    if (t.category === 'hosting')         k.hostingSpend   += Math.abs(t.amount)
    if (t.category === 'saas_tool')       k.saasSpend      += Math.abs(t.amount)
  }
  k.netProfit = k.totalIncome - k.totalExpense
  return k
}

export interface CategoryBreakdown { category: Category; total: number; count: number }

export function expensesByCategory(list: BankTransaction[]): CategoryBreakdown[] {
  const map = new Map<Category, CategoryBreakdown>()
  for (const t of list) {
    if (t.amount >= 0) continue
    const cur = map.get(t.category) ?? { category: t.category, total: 0, count: 0 }
    cur.total += Math.abs(t.amount)
    cur.count++
    map.set(t.category, cur)
  }
  return Array.from(map.values()).sort((a, b) => b.total - a.total)
}

export interface MonthlyDetail {
  month: string          // yyyy-mm
  monthLabel: string     // "Mai 2026"
  income: number
  expense: number
  net: number
  cashWithdrawn: number
  freelancesPaid: number
  adSpend: number
  txCount: number
  categories: { category: Category; total: number; count: number }[]
  topExpenses: BankTransaction[]
  topIncomes:  BankTransaction[]
}

function formatMonthLabel(yyyymm: string): string {
  const [y, m] = yyyymm.split('-').map(Number)
  const d = new Date(y, m - 1, 1)
  const s = d.toLocaleDateString('fr-FR', { month: 'long', year: 'numeric' })
  return s.charAt(0).toUpperCase() + s.slice(1)
}

export function monthlyDetailedStats(list: BankTransaction[]): MonthlyDetail[] {
  const groups = new Map<string, BankTransaction[]>()
  for (const t of list) {
    const key = t.date.slice(0, 7)
    const arr = groups.get(key) ?? []
    arr.push(t)
    groups.set(key, arr)
  }

  const out: MonthlyDetail[] = []
  for (const [month, txs] of groups) {
    let income = 0, expense = 0, cash = 0, freelance = 0, ads = 0
    const catMap = new Map<Category, { total: number; count: number }>()

    for (const t of txs) {
      if (t.amount >= 0) income += t.amount
      else                expense += Math.abs(t.amount)
      if (t.category === 'cash_withdrawal') cash     += Math.abs(t.amount)
      if (t.category === 'freelance')       freelance += Math.abs(t.amount)
      if (t.category === 'advertising')     ads      += Math.abs(t.amount)

      if (t.amount < 0) {
        const c = catMap.get(t.category) ?? { total: 0, count: 0 }
        c.total += Math.abs(t.amount)
        c.count++
        catMap.set(t.category, c)
      }
    }

    const categories = Array.from(catMap.entries())
      .map(([category, v]) => ({ category, ...v }))
      .sort((a, b) => b.total - a.total)

    const topExpenses = txs
      .filter(t => t.amount < 0)
      .sort((a, b) => Math.abs(b.amount) - Math.abs(a.amount))
      .slice(0, 5)

    const topIncomes = txs
      .filter(t => t.amount > 0)
      .sort((a, b) => b.amount - a.amount)
      .slice(0, 5)

    out.push({
      month,
      monthLabel: formatMonthLabel(month),
      income,
      expense,
      net: income - expense,
      cashWithdrawn: cash,
      freelancesPaid: freelance,
      adSpend: ads,
      txCount: txs.length,
      categories,
      topExpenses,
      topIncomes,
    })
  }

  return out.sort((a, b) => b.month.localeCompare(a.month))
}

export interface MonthlyPoint { month: string; income: number; expense: number; net: number }

export function monthlyEvolution(list: BankTransaction[]): MonthlyPoint[] {
  const map = new Map<string, MonthlyPoint>()
  for (const t of list) {
    const key = t.date.slice(0, 7) // yyyy-mm
    const cur = map.get(key) ?? { month: key, income: 0, expense: 0, net: 0 }
    if (t.amount >= 0) cur.income += t.amount
    else cur.expense += Math.abs(t.amount)
    cur.net = cur.income - cur.expense
    map.set(key, cur)
  }
  return Array.from(map.values()).sort((a, b) => a.month.localeCompare(b.month))
}

export interface Alert {
  id: string
  level: 'info' | 'warning' | 'critical'
  title: string
  message: string
}

/* Generates lightweight, rule-based insight alerts from the transaction set.
   Pure function — no API calls. */
export function generateAlerts(list: BankTransaction[]): Alert[] {
  const alerts: Alert[] = []
  if (list.length === 0) return alerts

  const months = monthlyEvolution(list)
  if (months.length >= 2) {
    const prev = months[months.length - 2]
    const cur  = months[months.length - 1]
    const prevAds = list
      .filter(t => t.date.startsWith(prev.month) && t.category === 'advertising')
      .reduce((s, t) => s + Math.abs(t.amount), 0)
    const curAds = list
      .filter(t => t.date.startsWith(cur.month) && t.category === 'advertising')
      .reduce((s, t) => s + Math.abs(t.amount), 0)
    if (prevAds > 0) {
      const delta = ((curAds - prevAds) / prevAds) * 100
      if (delta >= 25) alerts.push({
        id: 'ads-up',
        level: 'warning',
        title: 'Hausse des dépenses publicitaires',
        message: `Vos dépenses publicitaires ont augmenté de ${delta.toFixed(0)}% par rapport au mois précédent.`,
      })
    }
  }

  const cashThisMonth = list
    .filter(t => t.category === 'cash_withdrawal' && t.date.startsWith(new Date().toISOString().slice(0, 7)))
    .reduce((s, t) => s + Math.abs(t.amount), 0)
  if (cashThisMonth > 5000) alerts.push({
    id: 'cash-high',
    level: 'warning',
    title: 'Beaucoup de retraits cash ce mois',
    message: `Total retiré ce mois : ${cashThisMonth.toLocaleString('fr-MA')} MAD. Pensez à justifier ces sorties.`,
  })

  const incomeByLabel = new Map<string, number>()
  let totalIncome = 0
  for (const t of list) {
    if (!isIncomeCategory(t.category) || t.amount <= 0) continue
    totalIncome += t.amount
    const key = t.label.slice(0, 30)
    incomeByLabel.set(key, (incomeByLabel.get(key) ?? 0) + t.amount)
  }
  if (totalIncome > 0) {
    const top = Array.from(incomeByLabel.entries()).sort((a, b) => b[1] - a[1])[0]
    if (top) {
      const share = (top[1] / totalIncome) * 100
      if (share >= 40) alerts.push({
        id: 'client-dependency',
        level: 'critical',
        title: 'Forte dépendance à un client',
        message: `« ${top[0]} » représente ${share.toFixed(0)}% de votre chiffre d'affaires. Diversifiez votre portefeuille.`,
      })
    }
  }

  const recurring = detectRecurring(list)
  if (recurring.length > 0) alerts.push({
    id: 'recurring',
    level: 'info',
    title: `${recurring.length} abonnement(s) récurrent(s) détecté(s)`,
    message: `Dépenses qui reviennent chaque mois : ${recurring.slice(0, 3).map(r => r.label).join(', ')}${recurring.length > 3 ? '…' : ''}`,
  })

  return alerts
}

export function detectRecurring(list: BankTransaction[]): { label: string; avg: number; months: number }[] {
  const groups = new Map<string, BankTransaction[]>()
  for (const t of list) {
    if (t.amount >= 0) continue
    const key = t.label.toLowerCase().replace(/\d+/g, '').replace(/\s+/g, ' ').trim().slice(0, 40)
    const arr = groups.get(key) ?? []
    arr.push(t)
    groups.set(key, arr)
  }
  const out: { label: string; avg: number; months: number }[] = []
  for (const [, txs] of groups) {
    const months = new Set(txs.map(t => t.date.slice(0, 7)))
    if (months.size >= 2) {
      const avg = txs.reduce((s, t) => s + Math.abs(t.amount), 0) / txs.length
      out.push({ label: txs[0].label, avg, months: months.size })
    }
  }
  return out.sort((a, b) => b.months - a.months)
}

export function topClients(list: BankTransaction[], n = 5): { label: string; total: number }[] {
  const map = new Map<string, number>()
  for (const t of list) {
    if (!isIncomeCategory(t.category) || t.amount <= 0) continue
    const key = t.label.slice(0, 40)
    map.set(key, (map.get(key) ?? 0) + t.amount)
  }
  return Array.from(map.entries())
    .map(([label, total]) => ({ label, total }))
    .sort((a, b) => b.total - a.total)
    .slice(0, n)
}
