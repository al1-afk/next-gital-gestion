import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import { toast } from 'sonner'

export interface Depense {
  id: string
  created_at: string
  description: string
  montant: number
  categorie: string
  type: 'personnel' | 'professionnel'
  date_depense: string
}

const TABLE = 'depenses'

const MOCK_DEPENSES: Depense[] = [
  { id: '1', created_at: '2026-04-01', description: 'Abonnement Adobe CC', montant: 650, categorie: 'logiciels', type: 'professionnel', date_depense: '2026-04-01' },
  { id: '2', created_at: '2026-04-02', description: 'Déjeuner client', montant: 280, categorie: 'nourriture', type: 'professionnel', date_depense: '2026-04-02' },
  { id: '3', created_at: '2026-04-03', description: 'Essence voiture', montant: 400, categorie: 'transport', type: 'personnel', date_depense: '2026-04-03' },
  { id: '4', created_at: '2026-04-05', description: 'Hébergement serveur', montant: 1200, categorie: 'factures', type: 'professionnel', date_depense: '2026-04-05' },
  { id: '5', created_at: '2026-04-06', description: 'Fournitures bureau', montant: 350, categorie: 'shopping', type: 'professionnel', date_depense: '2026-04-06' },
  { id: '6', created_at: '2026-04-07', description: 'Courses alimentaires', montant: 520, categorie: 'nourriture', type: 'personnel', date_depense: '2026-04-07' },
  { id: '7', created_at: '2026-04-09', description: 'Formation React Advanced', montant: 1800, categorie: 'education', type: 'professionnel', date_depense: '2026-04-09' },
  { id: '8', created_at: '2026-04-10', description: 'Loyer bureau', montant: 3500, categorie: 'logement', type: 'professionnel', date_depense: '2026-04-10' },
]

export function useDepenses() {
  return useQuery({
    queryKey: [TABLE],
    queryFn: async () => {
      try {
        const { data, error } = await supabase.from(TABLE).select('*').order('date_depense', { ascending: false })
        if (error) throw error
        return data as Depense[]
      } catch {
        return MOCK_DEPENSES
      }
    },
    staleTime: 1000 * 60 * 3,
  })
}

export function useCreateDepense() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (data: Omit<Depense, 'id' | 'created_at'>) => {
      const { data: result, error } = await supabase.from(TABLE).insert(data).select().single()
      if (error) throw error
      return result
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Dépense ajoutée') },
    onError: () => toast.error('Erreur lors de la création'),
  })
}

export function useDeleteDepense() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from(TABLE).delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Dépense supprimée') },
    onError: () => toast.error('Erreur lors de la suppression'),
  })
}
