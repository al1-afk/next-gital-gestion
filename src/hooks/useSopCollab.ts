import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { sopSharesApi, sopTrainingApi } from '@/lib/api'
import { currentTenantIdForCache } from '@/lib/authToken'
import { toast } from 'sonner'

export type SopAccessLevel = 'read' | 'comment' | 'edit'

export interface SopShare {
  id:                 string
  tenant_id:          string
  sop_id:             string
  shared_by:          string | null
  shared_with:        string | null
  access_level:       SopAccessLevel
  public_link_token:  string | null
  is_active:          boolean
  expires_at:         string | null
  created_at:         string
  updated_at:         string
}

export interface SopTrainingEntry {
  id:           string
  tenant_id:    string
  sop_id:       string
  user_id:      string
  block_index:  number
  step_index:   number
  is_completed: boolean
  completed_at: string
  completed_by: string | null
  note:         string | null
  created_at:   string
  updated_at:   string
}

/* ── Partages ────────────────────────────────────────────────── */
const SHARES_KEY = 'sop_shares'

export function useSopShares() {
  return useQuery<SopShare[]>({
    queryKey: [SHARES_KEY, currentTenantIdForCache()],
    queryFn:  () => sopSharesApi.list({ orderBy: 'created_at', order: 'desc', limit: 500 }) as Promise<SopShare[]>,
    staleTime: 1000 * 60 * 2,
  })
}

export function useCreateSopShare() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: Pick<SopShare, 'sop_id' | 'shared_with' | 'access_level'> & { shared_by?: string | null; is_active?: boolean }) =>
      sopSharesApi.create(data as any) as Promise<SopShare>,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: [SHARES_KEY] })
      toast.success('SOP partagé')
    },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur lors du partage'),
  })
}

export function useUpdateSopShare() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<SopShare> & { id: string }) =>
      sopSharesApi.update(id, data) as Promise<SopShare>,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: [SHARES_KEY] })
      toast.success('Partage mis à jour')
    },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

export function useDeleteSopShare() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => sopSharesApi.remove(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: [SHARES_KEY] })
      toast.success('Accès retiré')
    },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/* ── Progression formation ───────────────────────────────────── */
const TRAINING_KEY = 'sop_training'

export function useSopTraining() {
  return useQuery<SopTrainingEntry[]>({
    queryKey: [TRAINING_KEY, currentTenantIdForCache()],
    queryFn:  () => sopTrainingApi.list({ orderBy: 'updated_at', order: 'desc', limit: 1000 }) as Promise<SopTrainingEntry[]>,
    staleTime: 1000 * 30,
  })
}

export function useUpsertTrainingStep() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (input: {
      sop_id:       string
      user_id:      string
      block_index:  number
      step_index:   number
      is_completed: boolean
      existing_id?: string
      note?:        string
    }) => {
      if (input.existing_id) {
        return sopTrainingApi.update(input.existing_id, {
          is_completed: input.is_completed,
          note:         input.note,
        } as any) as Promise<SopTrainingEntry>
      }
      return sopTrainingApi.create({
        sop_id:       input.sop_id,
        user_id:      input.user_id,
        block_index:  input.block_index,
        step_index:   input.step_index,
        is_completed: input.is_completed,
        note:         input.note ?? null,
      } as any) as Promise<SopTrainingEntry>
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TRAINING_KEY] }) },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur progression'),
  })
}

export function useDeleteTrainingStep() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => sopTrainingApi.remove(id),
    onSuccess: () => { qc.invalidateQueries({ queryKey: [TRAINING_KEY] }) },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}
