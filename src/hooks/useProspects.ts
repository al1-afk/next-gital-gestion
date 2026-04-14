import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import { toast }    from 'sonner'

/* ─── Types ──────────────────────────────────────────────────────── */
export type ProspectStatut =
  | 'nouveau'
  | 'contacte'
  | 'qualifie'
  | 'proposition'
  | 'gagne'
  | 'perdu'

export interface Prospect {
  id:              string
  created_at:      string
  nom:             string
  email:           string | null
  telephone:       string | null
  entreprise:      string | null
  statut:          ProspectStatut
  valeur_estimee:  number | null
  source:          string | null
  notes:           string | null
  responsable:     string | null
  date_contact:    string | null
  date_relance:    string | null
}

/* ─── Stage config ───────────────────────────────────────────────── */
export const PROSPECT_STAGES: {
  id:     ProspectStatut
  label:  string
  accent: string
  dot:    string
}[] = [
  { id: 'nouveau',     label: 'Nouveau',     accent: '#64748B', dot: 'bg-slate-400'   },
  { id: 'contacte',   label: 'Contacté',    accent: '#3B82F6', dot: 'bg-blue-500'    },
  { id: 'qualifie',   label: 'Qualifié',    accent: '#8B5CF6', dot: 'bg-violet-500'  },
  { id: 'proposition',label: 'Proposition', accent: '#F59E0B', dot: 'bg-amber-500'   },
  { id: 'gagne',      label: 'Gagné',       accent: '#10B981', dot: 'bg-emerald-500' },
  { id: 'perdu',      label: 'Perdu',       accent: '#EF4444', dot: 'bg-red-500'     },
]

export const PROSPECT_SOURCES = [
  'LinkedIn', 'Référence', 'Site web', 'Instagram',
  'Google Ads', 'Salon professionnel', 'Appel entrant', 'Autre',
]

/* ─── Mock store ─────────────────────────────────────────────────── */
// Use today's date so "À contacter aujourd'hui" always works in demo
const TODAY = new Date().toISOString().slice(0, 10)

let mockStore: Prospect[] = [
  { id: '1', created_at: '2026-04-12T10:00:00Z', nom: 'Ahmed Benali',   email: 'ahmed@startup.ma',    telephone: '0661234567', entreprise: 'Startup Tech MA',    statut: 'qualifie',    valeur_estimee: 15000, source: 'LinkedIn',            notes: 'Intéressé par le pack premium',   responsable: 'Said', date_contact: '2026-04-01', date_relance: TODAY },
  { id: '2', created_at: '2026-04-11T09:00:00Z', nom: 'Fatima Zahra',   email: 'fz@agence.ma',        telephone: '0662345678', entreprise: 'Agence Digital Plus', statut: 'proposition', valeur_estimee: 8500,  source: 'Référence',           notes: 'Devis envoyé le 5 avril',         responsable: 'Said', date_contact: '2026-04-02', date_relance: TODAY },
  { id: '3', created_at: '2026-04-10T14:00:00Z', nom: 'Karim Alaoui',   email: 'k.alaoui@corp.ma',    telephone: '0663456789', entreprise: 'Corp Solutions',      statut: 'proposition', valeur_estimee: 25000, source: 'Site web',            notes: 'En cours de négociation prix',    responsable: 'Said', date_contact: '2026-04-03', date_relance: TODAY },
  { id: '4', created_at: '2026-04-09T11:00:00Z', nom: 'Sara Idrissi',   email: 'sara@ecom.ma',        telephone: '0664567890', entreprise: 'E-Commerce MA',       statut: 'nouveau',     valeur_estimee: 5000,  source: 'Instagram',           notes: null,                              responsable: null,   date_contact: null,         date_relance: null },
  { id: '5', created_at: '2026-04-08T08:30:00Z', nom: 'Youssef Tazi',   email: 'y.tazi@hotel.ma',     telephone: '0665678901', entreprise: 'Hôtel Atlas',         statut: 'gagne',       valeur_estimee: 32000, source: 'Salon professionnel', notes: 'Contrat signé ✓',                 responsable: 'Said', date_contact: '2026-03-15', date_relance: null },
  { id: '6', created_at: '2026-04-07T15:00:00Z', nom: 'Nadia Mansouri', email: 'n.mansouri@rh.ma',    telephone: '0666789012', entreprise: 'Consulting RH',       statut: 'contacte',    valeur_estimee: 12000, source: 'LinkedIn',            notes: 'Premier RDV planifié',            responsable: 'Said', date_contact: '2026-04-06', date_relance: '2026-04-20' },
  { id: '7', created_at: '2026-04-06T10:00:00Z', nom: 'Omar Berrada',   email: 'o.berrada@import.ma', telephone: '0667890123', entreprise: 'Import Export MA',    statut: 'proposition', valeur_estimee: 18000, source: 'Référence',           notes: 'Première relance effectuée',      responsable: 'Said', date_contact: '2026-03-20', date_relance: '2026-04-25' },
  { id: '8', created_at: '2026-04-05T09:15:00Z', nom: 'Houda El Fassi', email: 'h.fassi@media.ma',    telephone: '0668901234', entreprise: 'Média Digital',       statut: 'perdu',       valeur_estimee: 9000,  source: 'Google Ads',          notes: 'A choisi un concurrent',          responsable: 'Said', date_contact: '2026-03-10', date_relance: null },
  { id: '9', created_at: '2026-04-04T16:00:00Z', nom: 'Rachid El Idrissi', email: 'r.idrissi@pharma.ma', telephone: '0669012345', entreprise: 'PharmaTech MA', statut: 'qualifie',    valeur_estimee: 22000, source: 'Site web',            notes: 'Demande démo produit',            responsable: 'Said', date_contact: '2026-04-04', date_relance: '2026-04-18' },
  { id: '10',created_at: '2026-04-03T11:45:00Z', nom: 'Amina Cherkaoui', email: 'a.cherkaoui@mode.ma', telephone: '0660123456', entreprise: 'Mode & Tendance',  statut: 'nouveau',     valeur_estimee: 7500,  source: 'Instagram',           notes: null,                              responsable: null,   date_contact: null,         date_relance: null },
]

const TABLE = 'prospects'

/* ─── useProspects ───────────────────────────────────────────────── */
export function useProspects() {
  return useQuery<Prospect[]>({
    queryKey: [TABLE],
    queryFn: async () => {
      try {
        const { data, error } = await supabase
          .from(TABLE)
          .select('*')
          .order('created_at', { ascending: false })
        if (error) throw error
        return data as Prospect[]
      } catch {
        return [...mockStore].sort(
          (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
        )
      }
    },
    staleTime: 1000 * 60 * 2,
  })
}

/* ─── useCreateProspect ──────────────────────────────────────────── */
export function useCreateProspect() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (data: Omit<Prospect, 'id' | 'created_at'>) => {
      try {
        const { data: res, error } = await supabase.from(TABLE).insert(data).select().single()
        if (error) throw error
        return res as Prospect
      } catch {
        const p: Prospect = { ...data, id: Date.now().toString(), created_at: new Date().toISOString() }
        mockStore = [p, ...mockStore]
        return p
      }
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Prospect créé') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur lors de la création'),
  })
}

/* ─── useUpdateProspect ──────────────────────────────────────────── */
export function useUpdateProspect() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async ({ id, ...data }: Partial<Prospect> & { id: string }) => {
      try {
        const { data: res, error } = await supabase.from(TABLE).update(data).eq('id', id).select().single()
        if (error) throw error
        return res as Prospect
      } catch {
        mockStore = mockStore.map(p => p.id === id ? { ...p, ...data } : p)
        return mockStore.find(p => p.id === id)!
      }
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Prospect mis à jour') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur lors de la mise à jour'),
  })
}

/* ─── useDeleteProspect ──────────────────────────────────────────── */
export function useDeleteProspect() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: string) => {
      try {
        const { error } = await supabase.from(TABLE).delete().eq('id', id)
        if (error) throw error
      } catch {
        mockStore = mockStore.filter(p => p.id !== id)
      }
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Prospect supprimé') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur lors de la suppression'),
  })
}
