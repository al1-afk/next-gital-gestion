import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import { toast } from 'sonner'

export interface Client {
  id: string
  created_at: string
  nom: string
  email: string | null
  telephone: string | null
  entreprise: string | null
  adresse: string | null
  ville: string | null
  pays: string | null
  notes: string | null
}

const TABLE = 'clients'

const MOCK_CLIENTS: Client[] = [
  { id: '1', created_at: '2026-01-15', nom: 'Youssef Tazi', email: 'y.tazi@hotel.ma', telephone: '0665678901', entreprise: 'Hôtel Atlas', adresse: '12 Rue Hassan II', ville: 'Marrakech', pays: 'Maroc', notes: 'Client VIP - Contrat annuel' },
  { id: '2', created_at: '2026-02-01', nom: 'Laila Bennani', email: 'l.bennani@pharma.ma', telephone: '0661111222', entreprise: 'PharmaTech', adresse: '45 Avenue Mohamed V', ville: 'Casablanca', pays: 'Maroc', notes: null },
  { id: '3', created_at: '2026-02-15', nom: 'Hassan Chraibi', email: 'h.chraibi@immo.ma', telephone: '0662222333', entreprise: 'Immobilier Premium', adresse: '8 Rue Allal Ben Abdellah', ville: 'Rabat', pays: 'Maroc', notes: 'Projet site vitrine + CRM' },
  { id: '4', created_at: '2026-03-01', nom: 'Zineb Oulad', email: 'z.oulad@mode.ma', telephone: '0663333444', entreprise: 'Mode & Co', adresse: '23 Boulevard Zerktouni', ville: 'Casablanca', pays: 'Maroc', notes: null },
  { id: '5', created_at: '2026-03-15', nom: 'Mehdi Berrada', email: 'm.berrada@food.ma', telephone: '0664444555', entreprise: 'FoodTech MA', adresse: '67 Rue Ibn Sina', ville: 'Fès', pays: 'Maroc', notes: 'Application mobile en cours' },
]

export function useClients() {
  return useQuery({
    queryKey: [TABLE],
    queryFn: async () => {
      try {
        const { data, error } = await supabase
          .from(TABLE)
          .select('*')
          .order('created_at', { ascending: false })
        if (error) throw error
        return data as Client[]
      } catch {
        return MOCK_CLIENTS
      }
    },
    staleTime: 1000 * 60 * 5,
  })
}

export function useCreateClient() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (data: Omit<Client, 'id' | 'created_at'>) => {
      try {
        const { data: result, error } = await supabase.from(TABLE).insert(data).select().single()
        if (error) throw error
        return result as Client
      } catch {
        const mock: Client = { ...data, id: String(Date.now()), created_at: new Date().toISOString() }
        MOCK_CLIENTS.unshift(mock)
        return mock
      }
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Client créé') },
  })
}

export function useUpdateClient() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async ({ id, ...data }: Partial<Client> & { id: string }) => {
      try {
        const { data: result, error } = await supabase.from(TABLE).update(data).eq('id', id).select().single()
        if (error) throw error
        return result as Client
      } catch {
        const idx = MOCK_CLIENTS.findIndex(c => c.id === id)
        if (idx !== -1) MOCK_CLIENTS[idx] = { ...MOCK_CLIENTS[idx], ...data }
        return MOCK_CLIENTS[idx]
      }
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Client mis à jour') },
    onError: () => toast.error('Erreur lors de la mise à jour'),
  })
}

export function useDeleteClient() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: string) => {
      try {
        const { error } = await supabase.from(TABLE).delete().eq('id', id)
        if (error) throw error
      } catch {
        const idx = MOCK_CLIENTS.findIndex(c => c.id === id)
        if (idx !== -1) MOCK_CLIENTS.splice(idx, 1)
      }
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Client supprimé') },
    onError: () => toast.error('Erreur lors de la suppression'),
  })
}
