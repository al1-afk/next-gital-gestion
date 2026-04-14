import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import { toast } from 'sonner'

/* ─── Types ──────────────────────────────────────────────────────── */
export type FactureStatut =
  | 'brouillon'
  | 'envoyee'
  | 'impayee'
  | 'partielle'
  | 'payee'
  | 'annulee'
  | 'refusee'

export interface Facture {
  id:             string
  created_at:     string
  numero:         string
  client_id:      string | null
  client_nom?:    string
  client_email?:  string
  statut:         FactureStatut
  date_emission:  string
  date_echeance:  string | null
  montant_ht:     number
  tva:            number
  montant_ttc:    number
  montant_paye:   number
  notes:          string | null
}

/* ─── Auto-statut helper ─────────────────────────────────────────── */
export function computeAutoStatut(
  montant_paye: number,
  montant_ttc:  number,
  current:      FactureStatut,
): FactureStatut {
  // These statuts are set deliberately by user, don't auto-change them
  if (['brouillon', 'annulee', 'refusee'].includes(current)) return current
  if (montant_paye >= montant_ttc && montant_ttc > 0) return 'payee'
  if (montant_paye > 0 && montant_paye < montant_ttc) return 'partielle'
  return current === 'envoyee' ? 'envoyee' : 'impayee'
}

/* ─── Mock store (used when Supabase is unavailable) ─────────────── */
let mockStore: Facture[] = [
  { id: '1', created_at: '2026-04-01', numero: 'FAC-2026-001', client_id: '1', client_nom: 'Hôtel Atlas',        statut: 'payee',     date_emission: '2026-04-01', date_echeance: '2026-04-30', montant_ht: 27118.64, tva: 20, montant_ttc: 32542.37, montant_paye: 32542.37, notes: null },
  { id: '2', created_at: '2026-04-03', numero: 'FAC-2026-002', client_id: '2', client_nom: 'PharmaTech',         statut: 'envoyee',   date_emission: '2026-04-03', date_echeance: '2026-05-03', montant_ht: 7083.33,  tva: 20, montant_ttc: 8500,     montant_paye: 0,         notes: null },
  { id: '3', created_at: '2026-03-15', numero: 'FAC-2026-003', client_id: '3', client_nom: 'Immobilier Premium', statut: 'partielle', date_emission: '2026-03-15', date_echeance: '2026-04-15', montant_ht: 10000,    tva: 20, montant_ttc: 12000,    montant_paye: 6000,      notes: 'Acompte 50% reçu' },
  { id: '4', created_at: '2026-04-08', numero: 'FAC-2026-004', client_id: '5', client_nom: 'FoodTech MA',        statut: 'impayee',   date_emission: '2026-04-08', date_echeance: '2026-04-10', montant_ht: 16666.67, tva: 20, montant_ttc: 20000,    montant_paye: 0,         notes: null },
  { id: '5', created_at: '2026-03-01', numero: 'FAC-2026-005', client_id: '4', client_nom: 'Mode & Co',          statut: 'payee',     date_emission: '2026-03-01', date_echeance: '2026-03-31', montant_ht: 4166.67,  tva: 20, montant_ttc: 5000,     montant_paye: 5000,      notes: null },
  { id: '6', created_at: '2026-04-10', numero: 'FAC-2026-006', client_id: '1', client_nom: 'Hôtel Atlas',        statut: 'brouillon', date_emission: '2026-04-10', date_echeance: '2026-05-10', montant_ht: 8000,     tva: 20, montant_ttc: 9600,     montant_paye: 0,         notes: 'En cours de rédaction' },
]

const TABLE = 'factures'

/* ─── Query helper ───────────────────────────────────────────────── */
function shapeRow(row: any): Facture {
  return {
    ...row,
    client_nom:   row.clients?.nom   ?? row.client_nom,
    client_email: row.clients?.email ?? row.client_email,
    clients:      undefined,
  }
}

/* ─── useFactures ────────────────────────────────────────────────── */
export function useFactures() {
  return useQuery<Facture[]>({
    queryKey: [TABLE],
    queryFn: async () => {
      try {
        const { data, error } = await supabase
          .from(TABLE)
          .select('*, clients(nom, email)')
          .order('created_at', { ascending: false })
        if (error) throw error
        return (data as any[]).map(shapeRow)
      } catch {
        return [...mockStore]
      }
    },
    staleTime: 1000 * 60 * 2,
  })
}

/* ─── useCreateFacture ───────────────────────────────────────────── */
export function useCreateFacture() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (data: Omit<Facture, 'id' | 'created_at' | 'client_nom' | 'client_email'>) => {
      try {
        const { data: res, error } = await supabase
          .from(TABLE).insert(data).select('*, clients(nom, email)').single()
        if (error) throw error
        return shapeRow(res)
      } catch {
        const newF: Facture = {
          ...data, id: Date.now().toString(), created_at: new Date().toISOString(),
        }
        mockStore = [newF, ...mockStore]
        return newF
      }
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Facture créée') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur lors de la création'),
  })
}

/* ─── useUpdateFacture ───────────────────────────────────────────── */
export function useUpdateFacture() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async ({ id, ...data }: Partial<Facture> & { id: string }) => {
      try {
        const { data: res, error } = await supabase
          .from(TABLE).update(data).eq('id', id).select('*, clients(nom, email)').single()
        if (error) throw error
        return shapeRow(res)
      } catch {
        mockStore = mockStore.map(f => f.id === id ? { ...f, ...data } : f)
        return mockStore.find(f => f.id === id)!
      }
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Facture mise à jour') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur lors de la mise à jour'),
  })
}

/* ─── useDeleteFacture ───────────────────────────────────────────── */
export function useDeleteFacture() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: string) => {
      try {
        const { error } = await supabase.from(TABLE).delete().eq('id', id)
        if (error) throw error
      } catch {
        mockStore = mockStore.filter(f => f.id !== id)
      }
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Facture supprimée') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur lors de la suppression'),
  })
}

/* ─── useMarkFacturePaid ─────────────────────────────────────────── */
export function useMarkFacturePaid() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (facture: Facture) => {
      const updates = { statut: 'payee' as FactureStatut, montant_paye: facture.montant_ttc }
      try {
        const { error } = await supabase.from(TABLE).update(updates).eq('id', facture.id)
        if (error) throw error
      } catch {
        mockStore = mockStore.map(f => f.id === facture.id ? { ...f, ...updates } : f)
      }
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Facture marquée comme payée ✓') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/* ─── useMarkFactureEnvoyee ──────────────────────────────────────── */
export function useMarkFactureEnvoyee() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: string) => {
      const updates = { statut: 'envoyee' as FactureStatut }
      try {
        const { error } = await supabase.from(TABLE).update(updates).eq('id', id)
        if (error) throw error
      } catch {
        mockStore = mockStore.map(f => f.id === id ? { ...f, ...updates } : f)
      }
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Facture marquée comme envoyée') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/* ─── useDuplicateFacture ────────────────────────────────────────── */
export function useDuplicateFacture() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (facture: Facture) => {
      const now  = new Date()
      const year = now.getFullYear()
      const num  = `FAC-${year}-${String(Date.now()).slice(-4)}`
      const newData = {
        numero:        num,
        client_id:     facture.client_id,
        statut:        'brouillon' as FactureStatut,
        date_emission: now.toISOString().slice(0, 10),
        date_echeance: null,
        montant_ht:    facture.montant_ht,
        tva:           facture.tva,
        montant_ttc:   facture.montant_ttc,
        montant_paye:  0,
        notes:         `Copie de ${facture.numero}${facture.notes ? ` — ${facture.notes}` : ''}`,
      }
      try {
        const { data: res, error } = await supabase
          .from(TABLE).insert(newData).select('*, clients(nom, email)').single()
        if (error) throw error
        return shapeRow(res)
      } catch {
        const newF: Facture = {
          ...newData, id: Date.now().toString(), created_at: now.toISOString(),
          client_nom: facture.client_nom, client_email: facture.client_email,
        }
        mockStore = [newF, ...mockStore]
        return newF
      }
    },
    onSuccess: (f) => {
      qc.invalidateQueries({ queryKey: [TABLE] })
      toast.success(`Dupliquée → ${f.numero}`)
    },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}
