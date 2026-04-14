import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '@/lib/supabase'
import { toast } from 'sonner'

export interface TeamMember {
  id: string
  created_at: string
  nom: string
  prenom: string
  email: string | null
  telephone: string | null
  poste: string | null
  departement: string | null
  salaire_base: number
  date_embauche: string | null
  statut: 'actif' | 'inactif' | 'conge'
}

const TABLE = 'team_members'

const MOCK_TEAM: TeamMember[] = [
  { id: '1', created_at: '2025-01-01', nom: 'El Amrani', prenom: 'Yassine', email: 'y.elamrani@nextgital.com', telephone: '0661000001', poste: 'Développeur Full Stack', departement: 'Tech', salaire_base: 8500, date_embauche: '2025-01-15', statut: 'actif' },
  { id: '2', created_at: '2025-03-01', nom: 'Cherkaoui', prenom: 'Meryem', email: 'm.cherkaoui@nextgital.com', telephone: '0661000002', poste: 'Designer UI/UX', departement: 'Design', salaire_base: 7000, date_embauche: '2025-03-01', statut: 'actif' },
  { id: '3', created_at: '2025-06-01', nom: 'Bensouda', prenom: 'Amine', email: 'a.bensouda@nextgital.com', telephone: '0661000003', poste: 'Commercial', departement: 'Ventes', salaire_base: 5500, date_embauche: '2025-06-01', statut: 'actif' },
  { id: '4', created_at: '2026-01-01', nom: 'Tahiri', prenom: 'Salma', email: 's.tahiri@nextgital.com', telephone: '0661000004', poste: 'Assistante Admin', departement: 'Admin', salaire_base: 4500, date_embauche: '2026-01-01', statut: 'conge' },
]

export function useTeam() {
  return useQuery({
    queryKey: [TABLE],
    queryFn: async () => {
      try {
        const { data, error } = await supabase.from(TABLE).select('*').order('created_at', { ascending: false })
        if (error) throw error
        return data as TeamMember[]
      } catch {
        return MOCK_TEAM
      }
    },
    staleTime: 1000 * 60 * 5,
  })
}

export function useCreateTeamMember() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (data: Omit<TeamMember, 'id' | 'created_at'>) => {
      const { data: result, error } = await supabase.from(TABLE).insert(data).select().single()
      if (error) throw error
      return result
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Membre ajouté') },
    onError: () => toast.error('Erreur lors de la création'),
  })
}

export function useUpdateTeamMember() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async ({ id, ...data }: Partial<TeamMember> & { id: string }) => {
      const { data: result, error } = await supabase.from(TABLE).update(data).eq('id', id).select().single()
      if (error) throw error
      return result
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Membre mis à jour') },
    onError: () => toast.error('Erreur lors de la mise à jour'),
  })
}

export function useDeleteTeamMember() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from(TABLE).delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TABLE] }); toast.success('Membre supprimé') },
    onError: () => toast.error('Erreur lors de la suppression'),
  })
}
