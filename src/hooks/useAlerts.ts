import { useMemo, useCallback } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useFactures } from './useFactures'
import { useProspects } from './useProspects'
import { useDepenses } from './useDepenses'
import { detectAnomalies, computeCashFlowProjection } from '@/lib/intelligence'

export type AlertPriority = 'low' | 'medium' | 'critical'
export type AlertType =
  | 'invoice_overdue_30' | 'invoice_overdue_7' | 'client_high_risk'
  | 'negative_cashflow' | 'no_recent_invoices' | 'domain_expiring'
  | 'revenue_concentration' | 'low_conversion' | 'high_loss_rate'
  | 'expense_surge' | 'no_revenue_7_days'

export interface Alert {
  id:          string
  type:        AlertType
  priority:    AlertPriority
  title:       string
  message:     string
  entity_type?: string
  entity_id?:  string
  link?:       string
  is_read:     boolean
  created_at:  string
}

const STORAGE_KEY = 'ng_alerts_read'

function getReadIds(): Set<string> {
  try {
    return new Set(JSON.parse(localStorage.getItem(STORAGE_KEY) ?? '[]'))
  } catch { return new Set() }
}

function markRead(id: string) {
  const ids = getReadIds()
  ids.add(id)
  localStorage.setItem(STORAGE_KEY, JSON.stringify([...ids]))
}

function markAllRead(ids: string[]) {
  const existing = getReadIds()
  ids.forEach(id => existing.add(id))
  localStorage.setItem(STORAGE_KEY, JSON.stringify([...existing]))
}

function daysBetween(dateStr: string | null): number {
  if (!dateStr) return 0
  return Math.floor((new Date().getTime() - new Date(dateStr).getTime()) / 86_400_000)
}

export function useAlerts() {
  const { data: factures  = [] } = useFactures()
  const { data: prospects = [] } = useProspects()
  const { data: depenses  = [] } = useDepenses()
  const qc = useQueryClient()

  const alerts = useMemo((): Alert[] => {
    const readIds  = getReadIds()
    const now      = new Date().toISOString()
    const result: Alert[] = []

    // ── Overdue invoices > 30 days
    factures
      .filter(f => (f.statut === 'impayee' || f.statut === 'partielle') && f.date_echeance)
      .forEach(f => {
        const days = daysBetween(f.date_echeance)
        if (days > 30) {
          result.push({
            id:          `overdue_30_${f.id}`,
            type:        'invoice_overdue_30',
            priority:    'critical',
            title:       `Facture en retard +${days}j`,
            message:     `${f.numero} · ${(f.montant_ttc - f.montant_paye).toLocaleString('fr-MA')} MAD`,
            entity_type: 'factures',
            entity_id:   f.id,
            link:        '/factures',
            is_read:     readIds.has(`overdue_30_${f.id}`),
            created_at:  now,
          })
        } else if (days > 7) {
          result.push({
            id:          `overdue_7_${f.id}`,
            type:        'invoice_overdue_7',
            priority:    'medium',
            title:       `Facture impayée depuis ${days}j`,
            message:     `${f.numero} · ${(f.montant_ttc - f.montant_paye).toLocaleString('fr-MA')} MAD`,
            entity_type: 'factures',
            entity_id:   f.id,
            link:        '/factures',
            is_read:     readIds.has(`overdue_7_${f.id}`),
            created_at:  now,
          })
        }
      })

    // ── Anomaly-based alerts from intelligence engine
    const anomalies = detectAnomalies(factures, prospects, depenses)
    anomalies.forEach(a => {
      const priorityMap: Record<string, AlertPriority> = {
        info: 'low', warning: 'medium', critical: 'critical',
      }
      result.push({
        id:          `anomaly_${a.id}`,
        type:        a.type as AlertType,
        priority:    priorityMap[a.severity] ?? 'medium',
        title:       a.title,
        message:     `${a.message} — ${a.recommendation}`,
        is_read:     readIds.has(`anomaly_${a.id}`),
        created_at:  now,
      })
    })

    // ── Cash flow projection
    const projection = computeCashFlowProjection(factures, depenses)
    if (projection.next30Days < 0) {
      result.push({
        id:          'cashflow_negative_30',
        type:        'negative_cashflow',
        priority:    'critical',
        title:       'Trésorerie projetée négative',
        message:     `Solde estimé J+30: ${Math.round(projection.next30Days).toLocaleString('fr-MA')} MAD`,
        link:        '/finances',
        is_read:     readIds.has('cashflow_negative_30'),
        created_at:  now,
      })
    }

    // Sort: critical first, then unread, then by "new-ness
    return result.sort((a, b) => {
      const priorityOrder = { critical: 0, medium: 1, low: 2 }
      const pa = priorityOrder[a.priority]
      const pb = priorityOrder[b.priority]
      if (pa !== pb) return pa - pb
      if (a.is_read !== b.is_read) return a.is_read ? 1 : -1
      return 0
    })
  }, [factures, prospects, depenses])

  const unreadCount    = useMemo(() => alerts.filter(a => !a.is_read).length, [alerts])
  const criticalCount  = useMemo(() => alerts.filter(a => a.priority === 'critical' && !a.is_read).length, [alerts])

  const dismiss = useCallback((id: string) => {
    markRead(id)
    qc.invalidateQueries({ queryKey: ['alerts'] })
  }, [qc])

  const dismissAll = useCallback(() => {
    markAllRead(alerts.map(a => a.id))
    qc.invalidateQueries({ queryKey: ['alerts'] })
  }, [alerts, qc])

  return { alerts, unreadCount, criticalCount, dismiss, dismissAll }
}
