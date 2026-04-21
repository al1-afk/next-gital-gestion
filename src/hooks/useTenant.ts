import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase, tenantDb } from '@/lib/supabase'
import { useTenant, useTenantId } from '@/contexts/TenantContext'
import { toast } from 'sonner'
import type { Role } from '@/lib/permissions'

export type MemberStatus = 'pending' | 'active' | 'revoked'

export interface TenantMember {
  id:          string
  tenant_id:   string
  user_id:     string | null
  role:        Role
  status:      MemberStatus
  invited_at:  string
  accepted_at: string | null
  email?:      string   // joined from auth.users via RPC
  full_name?:  string
}

/* ── List members of current tenant ─────────────────────────────── */
export function useTenantMembers() {
  const tenantId = useTenantId()
  return useQuery<TenantMember[]>({
    queryKey: ['tenant-members', tenantId],
    queryFn: async () => {
      const { data, error } = await tenantDb(tenantId)
        .from('tenant_users')
        .select('*')
        .eq('tenant_id', tenantId)
        .order('invited_at', { ascending: false })
      if (error) throw error
      return data as TenantMember[]
    },
    staleTime: 1000 * 60 * 5,
  })
}

/* ── Get current user's role in this tenant ──────────────────────── */
export function useMyRole() {
  const tenantId = useTenantId()
  return useQuery<Role>({
    queryKey: ['my-role', tenantId],
    queryFn: async () => {
      const { data, error } = await supabase.rpc('get_my_tenant_role', {
        p_tenant_id: tenantId,
      })
      if (error) throw error
      return (data as Role) ?? 'viewer'
    },
    staleTime: 1000 * 60 * 10,
  })
}

/* ── Invite a member ─────────────────────────────────────────────── */
export function useInviteMember() {
  const qc       = useQueryClient()
  const tenantId = useTenantId()
  return useMutation({
    mutationFn: async ({ email, role }: { email: string; role: Role }) => {
      const { data, error } = await supabase.rpc('invite_tenant_member', {
        p_email:     email,
        p_role:      role,
        p_tenant_id: tenantId,
      })
      if (error) throw error
      return data
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['tenant-members', tenantId] })
      toast.success('Invitation envoyée')
    },
    onError: (e: any) => toast.error(e.message ?? 'Erreur invitation'),
  })
}

/* ── Update member role ──────────────────────────────────────────── */
export function useUpdateMemberRole() {
  const qc       = useQueryClient()
  const tenantId = useTenantId()
  return useMutation({
    mutationFn: async ({ memberId, role }: { memberId: string; role: Role }) => {
      const { error } = await tenantDb(tenantId)
        .from('tenant_users')
        .update({ role })
        .eq('id', memberId)
        .eq('tenant_id', tenantId)
      if (error) throw error
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['tenant-members', tenantId] })
      toast.success('Rôle mis à jour')
    },
  })
}

/* ── Revoke member ───────────────────────────────────────────────── */
export function useRevokeMember() {
  const qc       = useQueryClient()
  const tenantId = useTenantId()
  return useMutation({
    mutationFn: async (memberId: string) => {
      const { error } = await tenantDb(tenantId)
        .from('tenant_users')
        .update({ status: 'revoked' })
        .eq('id', memberId)
        .eq('tenant_id', tenantId)
      if (error) throw error
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['tenant-members', tenantId] })
      toast.success('Accès révoqué')
    },
  })
}

/* ── Update tenant settings (admin only) ────────────────────────── */
export function useUpdateTenantSettings() {
  const qc            = useQueryClient()
  const { tenant }    = useTenant()
  return useMutation({
    mutationFn: async (patch: Partial<{
      name:          string
      logo_url:      string
      primary_color: string
      settings:      Record<string, unknown>
    }>) => {
      if (!tenant) throw new Error('No tenant')
      const { error } = await supabase
        .from('tenants')
        .update(patch)
        .eq('id', tenant.id)
      if (error) throw error
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['tenant'] })
      toast.success('Paramètres sauvegardés')
    },
  })
}

/* ── Register new company (public — before login) ────────────────── */
export async function registerTenant(params: {
  slug:   string
  name:   string
  plan?:  string
}): Promise<{ tenantId: string; error: string | null }> {
  const { data, error } = await supabase.rpc('create_tenant_with_owner', {
    p_slug:  params.slug.toLowerCase().replace(/\s+/g, '-'),
    p_name:  params.name,
    p_plan:  params.plan ?? 'starter',
  })
  if (error) return { tenantId: '', error: error.message }
  return { tenantId: data as string, error: null }
}

/* Re-export context hooks for convenience */
export { useTenant, useTenantId }
