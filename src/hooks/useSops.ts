import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { sopsApi } from '@/lib/api'
import { currentTenantIdForCache } from '@/lib/authToken'
import { toast } from 'sonner'

export type SopBlockType =
  | 'heading' | 'paragraph' | 'list' | 'checklist' | 'steps'
  | 'callout' | 'template' | 'code' | 'divider'

export interface SopBlock {
  type:    SopBlockType
  text?:   string
  items?:  string[]
  variant?:'info' | 'warning' | 'success' | 'tip'
  title?:  string
}

export interface Sop {
  id:          string
  tenant_id:   string
  slug:        string
  title:       string
  description: string | null
  category:    string
  tags:        string[]
  author:      string | null
  author_bg:   string
  read_min:    number
  views:       number
  popular:     boolean
  blocks:      SopBlock[]
  created_at:  string
  updated_at:  string
}

const KEY = 'sops'
const tk = () => [KEY, currentTenantIdForCache()] as const

export function useSops() {
  return useQuery<Sop[]>({
    queryKey: tk(),
    queryFn:  () => sopsApi.list({ orderBy: 'created_at', order: 'desc', limit: 500 }) as Promise<Sop[]>,
    staleTime: 1000 * 60 * 2,
  })
}

export function useCreateSop() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: Partial<Omit<Sop, 'id' | 'tenant_id' | 'created_at' | 'updated_at'>>) =>
      sopsApi.create(data as any) as Promise<Sop>,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: [KEY] })
      toast.success('SOP créé')
    },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

export function useUpdateSop() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<Sop> & { id: string }) =>
      sopsApi.update(id, data) as Promise<Sop>,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: [KEY] })
      toast.success('SOP mis à jour')
    },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

export function useDeleteSop() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => sopsApi.remove(id),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: [KEY] })
      toast.success('SOP supprimé')
    },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/** Génère un slug stable depuis un titre (pour la contrainte UNIQUE (tenant_id, slug)). */
export function makeSopSlug(title: string): string {
  return (
    title
      .toLowerCase()
      .normalize('NFD')
      .replace(/[̀-ͯ]/g, '')
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '')
      .slice(0, 60) || `sop-${Date.now()}`
  )
}
