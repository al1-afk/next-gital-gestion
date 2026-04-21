import {
  createContext, useContext, useState, useEffect, useCallback,
  type ReactNode,
} from 'react'
import { useParams } from 'react-router-dom'
import { tenantApi } from '@/lib/api'

/* ─── Types ──────────────────────────────────────────────────────── */
export type TenantPlan = 'starter' | 'pro' | 'enterprise'

export interface Tenant {
  id:            string
  slug:          string
  name:          string
  plan:          TenantPlan
  logo_url:      string | null
  primary_color: string
  is_active?:    boolean
}

interface TenantState {
  tenant:     Tenant | null
  loading:    boolean
  error:      string | null
  isDemoMode: boolean
}

interface TenantCtx extends TenantState {
  setTenantBySlug: (slug: string) => Promise<void>
  clearTenant:     () => void
}

/* ─── Demo fallback ──────────────────────────────────────────────── */
const DEMO_TENANT: Tenant = {
  id:            '00000000-0000-0000-0000-000000000001',
  slug:          'demo',
  name:          'GestiQ Demo',
  plan:          'pro',
  logo_url:      null,
  primary_color: '#2563EB',
}

/* ─── Context ────────────────────────────────────────────────────── */
const TenantContext = createContext<TenantCtx | null>(null)

export function TenantProvider({ children }: { children: ReactNode }) {
  const { tenantSlug } = useParams<{ tenantSlug: string }>()

  const [state, setState] = useState<TenantState>({
    tenant:     null,
    loading:    true,
    error:      null,
    isDemoMode: false,
  })

  const setTenantBySlug = useCallback(async (slug: string) => {
    setState(s => ({ ...s, loading: true, error: null }))
    try {
      const data = await tenantApi.resolve(slug)
      setState({
        tenant:     { ...data, plan: data.plan as TenantPlan, is_active: true },
        loading:    false,
        error:      null,
        isDemoMode: slug === 'demo',
      })
      sessionStorage.setItem('gestiq_tenant_slug', slug)
    } catch {
      /* Fallback to demo tenant so app still renders */
      setState({
        tenant:     { ...DEMO_TENANT, slug },
        loading:    false,
        error:      null,
        isDemoMode: true,
      })
    }
  }, [])

  const clearTenant = useCallback(() => {
    setState({ tenant: null, loading: false, error: null, isDemoMode: false })
    sessionStorage.removeItem('gestiq_tenant_slug')
  }, [])

  useEffect(() => {
    if (tenantSlug) setTenantBySlug(tenantSlug)
  }, [tenantSlug, setTenantBySlug])

  return (
    <TenantContext.Provider value={{ ...state, setTenantBySlug, clearTenant }}>
      {children}
    </TenantContext.Provider>
  )
}

/* ─── Hooks ──────────────────────────────────────────────────────── */
export function useTenant(): TenantCtx {
  const ctx = useContext(TenantContext)
  if (!ctx) throw new Error('useTenant must be used inside <TenantProvider>')
  return ctx
}

export function useTenantId(): string {
  const { tenant } = useTenant()
  return tenant?.id ?? DEMO_TENANT.id
}
