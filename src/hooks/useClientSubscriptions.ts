import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { clientSubsApi } from '@/lib/api'
import { toast } from 'sonner'

export interface ClientSubscription {
  id:                         string
  client_id:                  string | null
  client_nom:                 string
  nom:                        string
  montant:                    number
  cycle:                      'mensuel' | 'trimestriel' | 'annuel'
  montant_mensuel:            number
  date_debut:                 string
  date_prochaine_facturation: string
  statut:                     'actif' | 'pause' | 'annule' | 'impaye'
  date_annulation?:           string | null
  annulation_raison?:         string | null
  facture_auto:               boolean
}

export interface MrrMetrics {
  mrr:       number
  arr:       number
  churnRate: number
  atRisk:    number
}

export function computeMrrMetrics(subs: ClientSubscription[]): MrrMetrics {
  const active = subs.filter(s => s.statut === 'actif')
  const mrr    = active.reduce((sum, s) => sum + s.montant_mensuel, 0)
  const arr    = mrr * 12
  const atRisk = subs
    .filter(s => s.statut === 'impaye')
    .reduce((sum, s) => sum + s.montant_mensuel, 0)
  const total     = subs.length
  const cancelled = subs.filter(s => s.statut === 'annule').length
  const churnRate = total > 0 ? Math.round((cancelled / total) * 100) : 0
  return { mrr, arr, churnRate, atRisk }
}

const KEY = 'client_subscriptions'

export function useClientSubscriptions() {
  return useQuery<ClientSubscription[]>({
    queryKey: [KEY],
    queryFn:  () => clientSubsApi.list({ orderBy: 'created_at', order: 'desc' }) as Promise<ClientSubscription[]>,
    staleTime: 1000 * 60 * 2,
  })
}

export function useCreateClientSubscription() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: Omit<ClientSubscription, 'id'>) =>
      clientSubsApi.create(data) as Promise<ClientSubscription>,
    onSuccess: () => { qc.invalidateQueries({ queryKey: [KEY] }); toast.success('Abonnement créé') },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

export function useUpdateClientSubscription() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<ClientSubscription> & { id: string }) =>
      clientSubsApi.update(id, data) as Promise<ClientSubscription>,
    onSuccess: () => { qc.invalidateQueries({ queryKey: [KEY] }); toast.success('Abonnement mis à jour') },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

export function useDeleteClientSubscription() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => clientSubsApi.remove(id),
    onSuccess: () => { qc.invalidateQueries({ queryKey: [KEY] }); toast.success('Abonnement supprimé') },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

export const useCreateSubscription = useCreateClientSubscription
export const useUpdateSubscription = useUpdateClientSubscription
export const useDeleteSubscription = useDeleteClientSubscription
