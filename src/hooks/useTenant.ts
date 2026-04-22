import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { tenantApi, authApi } from '@/lib/api'
import { useTenant, useTenantId } from '@/contexts/TenantContext'
import { toast } from 'sonner'
import type { Role } from '@/lib/permissions'

/* ─────────────────────────────────────────────────────────────────
   Tenant / workspace hooks.

   All calls go through the Express `/api/tenants/*` layer, which
   enforces tenant isolation via `requireAuth` + `tenantQuery` + RLS.
   The legacy Supabase RPCs (`get_my_tenant_role`, `invite_tenant_member`,
   `create_tenant_with_owner`) were removed: they pointed at a
   placeholder Supabase project and bypassed the Express RBAC layer.
───────────────────────────────────────────────────────────────── */

export type MemberStatus = 'pending' | 'active' | 'revoked'

export interface TenantMember {
  id:          string
  tenant_id:   string
  user_id:     string | null
  role:        Role
  status:      MemberStatus
  invited_at:  string
  accepted_at: string | null
  email?:      string
  name?:       string
}

/* ── List members of current tenant ─────────────────────────────── */
export function useTenantMembers() {
  const tenantId = useTenantId()
  return useQuery<TenantMember[]>({
    queryKey: ['tenant-members', tenantId],
    enabled:  !!tenantId,
    queryFn:  () => tenantApi.members() as Promise<TenantMember[]>,
    staleTime: 1000 * 60 * 5,
  })
}

/* ── Get current user's role in this tenant ──────────────────────── */
export function useMyRole() {
  const tenantId = useTenantId()
  return useQuery<Role>({
    queryKey: ['my-role', tenantId],
    enabled:  !!tenantId,
    queryFn: async () => {
      const me = await authApi.me()
      return (me.role as Role) ?? 'viewer'
    },
    staleTime: 1000 * 60 * 10,
  })
}

/* ── Invite a member ─────────────────────────────────────────────── */
export function useInviteMember() {
  const qc       = useQueryClient()
  const tenantId = useTenantId()
  return useMutation({
    mutationFn: ({ email, role }: { email: string; role: Role }) =>
      tenantApi.invite(email, role),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['tenant-members', tenantId] })
      toast.success('Invitation envoyée')
    },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur invitation'),
  })
}

/* ── Revoke member ───────────────────────────────────────────────── */
export function useRevokeMember() {
  const qc       = useQueryClient()
  const tenantId = useTenantId()
  return useMutation({
    mutationFn: (memberId: string) => tenantApi.revokeMember(memberId),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['tenant-members', tenantId] })
      toast.success('Accès révoqué')
    },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/* ── Update tenant settings (admin only — enforced server-side) ──── */
export function useUpdateTenantSettings() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (patch: Partial<{
      name:          string
      logo_url:      string
      primary_color: string
      settings:      Record<string, unknown>
    }>) => tenantApi.update(patch),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['tenant'] })
      toast.success('Paramètres sauvegardés')
    },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/* Re-export context hooks for convenience */
export { useTenant, useTenantId }
