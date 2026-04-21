import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { prospectsApi } from '@/lib/api'
import { toast } from 'sonner'

export type ProspectStatut = 'nouveau' | 'contacte' | 'qualifie' | 'proposition' | 'gagne' | 'perdu'

export interface Prospect {
  id:             string
  created_at:     string
  nom:            string
  email:          string | null
  telephone:      string | null
  entreprise:     string | null
  statut:         ProspectStatut
  valeur_estimee: number | null
  source:         string | null
  notes:          string | null
  responsable:    string | null
  date_contact:   string | null
  date_relance:   string | null
}

export const PROSPECT_STAGES: { id: ProspectStatut; label: string; accent: string; dot: string }[] = [
  { id: 'nouveau',      label: 'Nouveau',     accent: '#64748B', dot: 'bg-slate-400'   },
  { id: 'contacte',    label: 'Contacté',    accent: '#3B82F6', dot: 'bg-blue-500'    },
  { id: 'qualifie',    label: 'Qualifié',    accent: '#8B5CF6', dot: 'bg-violet-500'  },
  { id: 'proposition', label: 'Proposition', accent: '#F59E0B', dot: 'bg-amber-500'   },
  { id: 'gagne',       label: 'Gagné',       accent: '#10B981', dot: 'bg-emerald-500' },
  { id: 'perdu',       label: 'Perdu',       accent: '#EF4444', dot: 'bg-red-500'     },
]

export const PROSPECT_SOURCES = [
  'LinkedIn', 'Référence', 'Site web', 'Instagram',
  'Google Ads', 'Salon professionnel', 'Appel entrant', 'Autre',
]

const KEY = 'prospects'

export function useProspects() {
  return useQuery<Prospect[]>({
    queryKey: [KEY],
    queryFn:  () => prospectsApi.list({ orderBy: 'created_at', order: 'desc' }) as Promise<Prospect[]>,
    staleTime: 1000 * 60 * 2,
  })
}

export function useCreateProspect() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: Omit<Prospect, 'id' | 'created_at'>) =>
      prospectsApi.create(data) as Promise<Prospect>,
    onSuccess: () => { qc.invalidateQueries({ queryKey: [KEY] }); toast.success('Prospect créé') },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

export function useUpdateProspect() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<Prospect> & { id: string }) =>
      prospectsApi.update(id, data) as Promise<Prospect>,
    onSuccess: () => { qc.invalidateQueries({ queryKey: [KEY] }); toast.success('Prospect mis à jour') },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

export function useDeleteProspect() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => prospectsApi.remove(id),
    onSuccess: () => { qc.invalidateQueries({ queryKey: [KEY] }); toast.success('Prospect supprimé') },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}
