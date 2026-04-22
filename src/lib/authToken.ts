import { tokenStore } from './api'

/* ─────────────────────────────────────────────────────────────────
   Tenant/user accessors that work OUTSIDE React (hooks, interceptors,
   IndexedDB names) by decoding the JWT from localStorage.

   We DO NOT verify the signature here — this is only used to build
   cache keys and DB names. The server is the single source of truth
   for tenant_id enforcement.
───────────────────────────────────────────────────────────────── */

interface Claims {
  userId?:   string
  email?:    string
  tenantId?: string
  role?:     string
  exp?:      number
}

function decodeJwt(token: string): Claims | null {
  try {
    const [, payload] = token.split('.')
    if (!payload) return null
    const json = atob(payload.replace(/-/g, '+').replace(/_/g, '/'))
    return JSON.parse(json) as Claims
  } catch {
    return null
  }
}

export function currentClaims(): Claims | null {
  const t = tokenStore.get()
  if (!t) return null
  const c = decodeJwt(t)
  if (!c) return null
  if (c.exp && c.exp * 1000 < Date.now()) return null
  return c
}

/** Stable tenant identifier for cache keys. Returns '__anon__' when
 *  unauthenticated — this guarantees a different cache namespace than
 *  any real tenant (real tenants are UUIDs). */
export function currentTenantIdForCache(): string {
  return currentClaims()?.tenantId ?? '__anon__'
}

export function currentUserId(): string | null {
  return currentClaims()?.userId ?? null
}

export function currentRole(): string | null {
  return currentClaims()?.role ?? null
}
