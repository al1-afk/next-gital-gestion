import type { Facture } from '@/hooks/useFactures'
import type { Prospect } from '@/hooks/useProspects'
import type { Depense } from '@/hooks/useDepenses'

export interface CashFlowItem {
  label: string
  date:  string
  amount: number
  type: 'inflow' | 'outflow'
  probability: number
  source: 'invoice' | 'subscription' | 'expense'
}

export interface CashFlowProjection {
  next30Days: number
  next7Days:  number
  expectedInflows:  number
  expectedOutflows: number
  items: CashFlowItem[]
  avgMonthlyExpenses: number
  avgDaysToPay: number
}

export interface Anomaly {
  id:             string
  type:           string
  severity:       'info' | 'warning' | 'critical'
  title:          string
  message:        string
  recommendation: string
  value?:         number
}

// Probability an overdue invoice will be collected
function collectionProbability(daysOverdue: number): number {
  if (daysOverdue <= 0)  return 0.90
  if (daysOverdue <= 7)  return 0.75
  if (daysOverdue <= 15) return 0.55
  if (daysOverdue <= 30) return 0.35
  if (daysOverdue <= 60) return 0.15
  return 0.05
}

function daysBetween(dateStr: string | null, now = new Date()): number {
  if (!dateStr) return 0
  return Math.floor((now.getTime() - new Date(dateStr).getTime()) / 86_400_000)
}

function addDays(days: number, from = new Date()): string {
  const d = new Date(from)
  d.setDate(d.getDate() + days)
  return d.toISOString().slice(0, 10)
}

export function computeCashFlowProjection(
  factures: Facture[],
  depenses: Depense[],
): CashFlowProjection {
  const now = new Date()
  const horizon = 30 // days forward

  // Average days-to-pay from paid invoices (last 90 days)
  const recentPaid = factures.filter(f => f.statut === 'payee')
  const avgDaysToPay = recentPaid.length > 0
    ? recentPaid.reduce((s, f) => {
        const emit  = new Date(f.date_emission).getTime()
        const paid  = new Date(f.created_at).getTime()
        return s + (paid - emit) / 86_400_000
      }, 0) / recentPaid.length
    : 14

  // Expected inflows: open invoices
  const inflowItems: CashFlowItem[] = factures
    .filter(f => f.statut === 'impayee' || f.statut === 'partielle')
    .map(f => {
      const remaining   = f.montant_ttc - f.montant_paye
      const daysOverdue = daysBetween(f.date_echeance)
      const prob        = collectionProbability(daysOverdue)
      const expectedDate = daysOverdue > 0
        ? addDays(Math.round(avgDaysToPay * 0.5))
        : addDays(Math.max(0, -daysOverdue + 3))
      return {
        label:       f.numero,
        date:        expectedDate,
        amount:      remaining,
        type:        'inflow' as const,
        probability: prob,
        source:      'invoice' as const,
      }
    })
    .filter(item => {
      const daysUntil = -daysBetween(item.date)
      return daysUntil >= 0 && daysUntil <= horizon
    })

  // Average monthly burn from last 3 months of expenses
  const threeMonthsAgo = new Date()
  threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3)
  const recentExpenses = depenses.filter(d => new Date(d.date_depense) >= threeMonthsAgo)
  const avgMonthlyExpenses = recentExpenses.length > 0
    ? recentExpenses.reduce((s, d) => s + d.montant, 0) / 3
    : 0

  // Project 30-day expense outflow
  const dailyBurn = avgMonthlyExpenses / 30
  const outflowItems: CashFlowItem[] = Array.from({ length: 4 }, (_, i) => ({
    label:       `Dépenses sem. ${i + 1}`,
    date:        addDays((i + 1) * 7),
    amount:      dailyBurn * 7,
    type:        'outflow' as const,
    probability: 1,
    source:      'expense' as const,
  }))

  const expectedInflows  = inflowItems.reduce((s, i) => s + i.amount * i.probability, 0)
  const expectedOutflows = avgMonthlyExpenses

  return {
    next30Days:         expectedInflows - expectedOutflows,
    next7Days:          inflowItems.filter(i => -daysBetween(i.date) <= 7)
                          .reduce((s, i) => s + i.amount * i.probability, 0)
                        - dailyBurn * 7,
    expectedInflows,
    expectedOutflows,
    items:              [...inflowItems, ...outflowItems],
    avgMonthlyExpenses,
    avgDaysToPay:       Math.round(avgDaysToPay),
  }
}

export function detectAnomalies(
  factures: Facture[],
  prospects: Prospect[],
  depenses: Depense[],
): Anomaly[] {
  const anomalies: Anomaly[] = []
  const now = new Date()

  // ── 1. Revenue concentration risk
  const paidByClient: Record<string, number> = {}
  factures.filter(f => f.statut === 'payee').forEach(f => {
    if (f.client_id) {
      paidByClient[f.client_id] = (paidByClient[f.client_id] ?? 0) + f.montant_ttc
    }
  })
  const totalRevenue = Object.values(paidByClient).reduce((s, v) => s + v, 0)
  if (totalRevenue > 0) {
    const topAmount = Math.max(...Object.values(paidByClient))
    const topShare  = topAmount / totalRevenue
    if (topShare > 0.40) {
      anomalies.push({
        id:             'revenue_concentration',
        type:           'revenue_concentration',
        severity:       'critical',
        title:          'Concentration de revenus élevée',
        message:        `Un seul client représente ${(topShare * 100).toFixed(0)}% de votre CA`,
        recommendation: 'Diversifiez votre portefeuille client. Un départ causerait une perte critique.',
        value:          topShare,
      })
    }
  }

  // ── 2. Pipeline conversion drop (this month vs prospected total)
  const total     = prospects.length
  const won       = prospects.filter(p => p.statut === 'gagne').length
  const lost      = prospects.filter(p => p.statut === 'perdu').length
  const convRate  = total > 0 ? won / total : 0
  if (total >= 5 && convRate < 0.15) {
    anomalies.push({
      id:             'low_conversion',
      type:           'low_conversion',
      severity:       'warning',
      title:          'Taux de conversion faible',
      message:        `Seulement ${(convRate * 100).toFixed(0)}% de vos prospects deviennent clients`,
      recommendation: 'Analysez les motifs de refus. Améliorez votre suivi devis.',
      value:          convRate,
    })
  }

  // ── 3. High loss rate
  const closedTotal = won + lost
  const lossRate    = closedTotal > 0 ? lost / closedTotal : 0
  if (closedTotal >= 3 && lossRate > 0.60) {
    anomalies.push({
      id:             'high_loss_rate',
      type:           'high_loss_rate',
      severity:       'warning',
      title:          'Taux de perte élevé',
      message:        `${(lossRate * 100).toFixed(0)}% de vos opportunités fermées sont perdues`,
      recommendation: 'Identifiez les concurrents qui gagnent contre vous et ajustez votre offre.',
      value:          lossRate,
    })
  }

  // ── 4. Multiple overdue invoices for same client
  const overdueByClient: Record<string, number> = {}
  factures.filter(f => f.statut === 'impayee' && f.date_echeance)
    .forEach(f => {
      if (!f.client_id) return
      const overdue = daysBetween(f.date_echeance)
      if (overdue > 0) {
        overdueByClient[f.client_id] = (overdueByClient[f.client_id] ?? 0) + 1
      }
    })
  const riskyClients = Object.entries(overdueByClient).filter(([, count]) => count >= 2)
  if (riskyClients.length > 0) {
    anomalies.push({
      id:             'client_high_risk',
      type:           'client_high_risk',
      severity:       'critical',
      title:          `${riskyClients.length} client(s) à risque de non-paiement`,
      message:        `Ces clients ont 2 factures impayées ou plus en retard`,
      recommendation: 'Suspendez les nouvelles prestations pour ces clients. Contactez-les immédiatement.',
      value:          riskyClients.length,
    })
  }

  // ── 5. No invoices issued in last 14 days
  const twoWeeksAgo = new Date()
  twoWeeksAgo.setDate(twoWeeksAgo.getDate() - 14)
  const recentInvoices = factures.filter(f =>
    new Date(f.date_emission) >= twoWeeksAgo
  )
  if (factures.length > 0 && recentInvoices.length === 0) {
    anomalies.push({
      id:             'no_recent_invoices',
      type:           'no_recent_invoices',
      severity:       'warning',
      title:          'Aucune facture émise depuis 14 jours',
      message:        'Votre activité de facturation est en pause',
      recommendation: 'Convertissez vos devis acceptés en factures et relancez vos clients.',
    })
  }

  // ── 6. Expense growth (this month vs last month)
  const thisMonth  = now.getMonth()
  const thisYear   = now.getFullYear()
  const lastMonth  = thisMonth === 0 ? 11 : thisMonth - 1
  const lastYear   = thisMonth === 0 ? thisYear - 1 : thisYear

  const thisMonthExp = depenses.filter(d => {
    const dd = new Date(d.date_depense)
    return dd.getMonth() === thisMonth && dd.getFullYear() === thisYear
  }).reduce((s, d) => s + d.montant, 0)

  const lastMonthExp = depenses.filter(d => {
    const dd = new Date(d.date_depense)
    return dd.getMonth() === lastMonth && dd.getFullYear() === lastYear
  }).reduce((s, d) => s + d.montant, 0)

  if (lastMonthExp > 0 && thisMonthExp > lastMonthExp * 1.4) {
    const growth = ((thisMonthExp - lastMonthExp) / lastMonthExp * 100).toFixed(0)
    anomalies.push({
      id:             'expense_surge',
      type:           'expense_surge',
      severity:       'warning',
      title:          `Dépenses en hausse de ${growth}%`,
      message:        `Ce mois: ${thisMonthExp.toLocaleString()} MAD vs ${lastMonthExp.toLocaleString()} MAD le mois dernier`,
      recommendation: 'Auditez les nouvelles dépenses. Identifiez les postes à optimiser.',
      value:          Number(growth),
    })
  }

  return anomalies
}

export function computePipelineMetrics(prospects: Prospect[]) {
  const stages = ['nouveau', 'contacte', 'qualifie', 'proposition', 'gagne', 'perdu'] as const

  const byStage = Object.fromEntries(
    stages.map(s => [s, prospects.filter(p => p.statut === s)])
  )

  const funnelData = stages.slice(0, -1).map((stage, i) => {
    const current = byStage[stage].length
    const next    = byStage[stages[i + 1]]?.length ?? 0
    const rate    = current > 0 ? ((next / current) * 100).toFixed(1) : '0'
    const value   = byStage[stage].reduce((s, p) => s + (p.valeur_estimee ?? 0), 0)
    return { stage, count: current, rate: Number(rate), value }
  })

  // Source ROI
  const sourceMap: Record<string, { leads: number; won: number; revenue: number }> = {}
  prospects.forEach(p => {
    const src = p.source ?? 'Autre'
    if (!sourceMap[src]) sourceMap[src] = { leads: 0, won: 0, revenue: 0 }
    sourceMap[src].leads++
    if (p.statut === 'gagne') {
      sourceMap[src].won++
      sourceMap[src].revenue += p.valeur_estimee ?? 0
    }
  })

  const sourceData = Object.entries(sourceMap).map(([source, data]) => ({
    source,
    leads: data.leads,
    won:   data.won,
    conversion: data.leads > 0 ? Number((data.won / data.leads * 100).toFixed(1)) : 0,
    revenue:    data.revenue,
    avgDeal:    data.won > 0 ? Math.round(data.revenue / data.won) : 0,
  })).sort((a, b) => b.revenue - a.revenue)

  return { byStage, funnelData, sourceData }
}
