import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import { toast } from 'sonner'

export interface DevisLine {
  id: string
  description: string
  quantite: number
  prix_unitaire: number
  total: number
}

export interface Devis {
  id: string
  created_at: string
  numero: string
  client_id: string | null
  client_nom?: string
  statut: 'brouillon' | 'envoye' | 'accepte' | 'refuse' | 'expire'
  date_emission: string
  date_expiration: string | null
  montant_ht: number
  tva: number
  montant_ttc: number
  notes: string | null
  lignes?: DevisLine[]
}

const TABLE = 'devis'

const MOCK_DEVIS: Devis[] = [
  { id: '1', created_at: '2026-04-01', numero: 'DEV-2026-001', client_id: '1', client_nom: 'Hôtel Atlas', statut: 'accepte', date_emission: '2026-04-01', date_expiration: '2026-05-01', montant_ht: 27118.64, tva: 20, montant_ttc: 32542.37, notes: 'Pack site web + SEO' },
  { id: '2', created_at: '2026-04-03', numero: 'DEV-2026-002', client_id: '2', client_nom: 'PharmaTech', statut: 'envoye', date_emission: '2026-04-03', date_expiration: '2026-05-03', montant_ht: 7083.33, tva: 20, montant_ttc: 8500, notes: 'Application mobile' },
  { id: '3', created_at: '2026-04-05', numero: 'DEV-2026-003', client_id: '3', client_nom: 'Immobilier Premium', statut: 'brouillon', date_emission: '2026-04-05', date_expiration: '2026-05-05', montant_ht: 10000, tva: 20, montant_ttc: 12000, notes: null },
  { id: '4', created_at: '2026-03-15', numero: 'DEV-2026-004', client_id: '4', client_nom: 'Mode & Co', statut: 'refuse', date_emission: '2026-03-15', date_expiration: '2026-04-15', montant_ht: 5000, tva: 20, montant_ttc: 6000, notes: 'Budget insuffisant' },
  { id: '5', created_at: '2026-04-08', numero: 'DEV-2026-005', client_id: '5', client_nom: 'FoodTech MA', statut: 'envoye', date_emission: '2026-04-08', date_expiration: '2026-05-08', montant_ht: 16666.67, tva: 20, montant_ttc: 20000, notes: 'Plateforme e-commerce' },
]

export function useDevis() {
  return useQuery({
    queryKey: [TABLE],
    queryFn: async () => {
      const { data, error } = await supabase.from(TABLE).select('*').order('created_at', { ascending: false })
      if (error) {
        // In development fall back to mock data so UI stays usable without a DB
        if (import.meta.env.DEV) return MOCK_DEVIS
        throw error
      }
      return data as Devis[]
    },
    staleTime: 1000 * 60 * 3,
  })
}

export function useCreateDevis() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (data: Omit<Devis, 'id' | 'created_at'>) => {
      if (import.meta.env.DEV) {
        try {
          const { data: result, error } = await supabase.from(TABLE).insert(data).select().single()
          if (error) throw error
          return result as Devis
        } catch {
          const mock: Devis = { ...data, id: String(Date.now()), created_at: new Date().toISOString() }
          MOCK_DEVIS.unshift(mock)
          return mock
        }
      }
      const { data: result, error } = await supabase.from(TABLE).insert(data).select().single()
      if (error) throw error
      return result as Devis
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Devis créé') },
  })
}

export function useUpdateDevis() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async ({ id, ...data }: Partial<Devis> & { id: string }) => {
      if (import.meta.env.DEV) {
        try {
          const { data: result, error } = await supabase.from(TABLE).update(data).eq('id', id).select().single()
          if (error) throw error
          return result as Devis
        } catch {
          const idx = MOCK_DEVIS.findIndex(d => d.id === id)
          if (idx !== -1) MOCK_DEVIS[idx] = { ...MOCK_DEVIS[idx], ...data }
          return MOCK_DEVIS[idx]
        }
      }
      const { data: result, error } = await supabase.from(TABLE).update(data).eq('id', id).select().single()
      if (error) throw error
      return result as Devis
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Devis mis à jour') },
    onError: () => toast.error('Erreur lors de la mise à jour'),
  })
}

export function useDeleteDevis() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: string) => {
      if (import.meta.env.DEV) {
        try {
          const { error } = await supabase.from(TABLE).delete().eq('id', id)
          if (error) throw error
          return
        } catch {
          const idx = MOCK_DEVIS.findIndex(d => d.id === id)
          if (idx !== -1) MOCK_DEVIS.splice(idx, 1)
          return
        }
      }
      const { error } = await supabase.from(TABLE).delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Devis supprimé') },
    onError: () => toast.error('Erreur lors de la suppression'),
  })
}
