/* ─────────────────────────────────────────────────────────────────
   GestiQ API Client — remplace Supabase
   Toutes les requêtes sont envoyées à Express + PostgreSQL
───────────────────────────────────────────────────────────────── */

const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000'

/* ── Token storage ───────────────────────────────────────────── */
export const tokenStore = {
  get:    ()        => localStorage.getItem('gestiq_token') ?? '',
  set:    (t: string) => localStorage.setItem('gestiq_token', t),
  clear:  ()        => localStorage.removeItem('gestiq_token'),
}

/* ── Token refresh (singleton promise — prevents parallel refreshes) */
let _refreshPromise: Promise<string> | null = null

async function refreshAccessToken(): Promise<string> {
  if (_refreshPromise) return _refreshPromise
  _refreshPromise = fetch(`${BASE_URL}/api/auth/refresh`, {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' },
  })
    .then(r => r.json())
    .then(d => {
      if (!d.token) throw new Error('refresh_failed')
      tokenStore.set(d.token)
      return d.token as string
    })
    .finally(() => { _refreshPromise = null })
  return _refreshPromise
}

/* ── Base fetch ──────────────────────────────────────────────── */
async function request<T>(
  method:  string,
  path:    string,
  body?:   unknown,
  auth     = true,
  _retry   = true,
): Promise<T> {
  const headers: Record<string, string> = { 'Content-Type': 'application/json' }
  if (auth) headers['Authorization'] = `Bearer ${tokenStore.get()}`

  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    headers,
    credentials: 'include',
    body: body !== undefined ? JSON.stringify(body) : undefined,
  })

  /* Auto-refresh on 401 TOKEN_EXPIRED */
  if (res.status === 401 && auth && _retry) {
    const data = await res.json().catch(() => ({}))
    if (data.code === 'TOKEN_EXPIRED') {
      try {
        await refreshAccessToken()
        return request<T>(method, path, body, auth, false)
      } catch {
        /* Refresh failed — purge every client-side cache so the
           next user on this browser cannot see stale data. */
        const { purgeClientSession } = await import('./session')
        await purgeClientSession()
        window.location.href = '/auth'
        throw new Error('Session expirée')
      }
    }
    /* TOKEN_REUSE (session hijack detected) or other hard 401 —
       same cleanup, the user is being force-logged-out. */
    if (data.code === 'TOKEN_REUSE' || data.code === 'NO_REFRESH' || data.code === 'INVALID_REFRESH') {
      const { purgeClientSession } = await import('./session')
      await purgeClientSession()
      window.location.href = '/auth'
    }
    throw new Error(data.error ?? 'Non authentifié')
  }

  const data = await res.json().catch(() => ({}))
  if (!res.ok) throw new Error(data.error ?? `HTTP ${res.status}`)
  return data as T
}

/* ── Shorthand helpers ───────────────────────────────────────── */
export const api = {
  get:    <T>(path: string)                  => request<T>('GET',    path),
  post:   <T>(path: string, body: unknown)   => request<T>('POST',   path, body),
  patch:  <T>(path: string, body: unknown)   => request<T>('PATCH',  path, body),
  delete: <T>(path: string)                  => request<T>('DELETE', path),
  publicGet: <T>(path: string)               => request<T>('GET',    path, undefined, false),
  publicPost:<T>(path: string, body: unknown)=> request<T>('POST',   path, body, false),
}

/* ── Auth API ────────────────────────────────────────────────── */
export const authApi = {
  login: (email: string, password: string, tenantSlug?: string) =>
    api.publicPost<{ token: string; tenantSlug: string; tenantId: string; role: string }>(
      '/api/auth/login', { email, password, tenantSlug }
    ),

  register: (data: { email: string; password: string; name: string; tenantSlug: string; tenantName: string }) =>
    api.publicPost<{ token: string; tenantSlug: string; tenantId: string }>(
      '/api/auth/register', data
    ),

  me: () => api.get<{
    id: string; email: string; name: string; role: string;
    slug: string; tenant_name: string; plan: string;
    allowed_modules: string[] | null;
  }>('/api/auth/me'),

  forgotPassword: (email: string) =>
    api.publicPost<{ success: boolean }>('/api/auth/forgot-password', { email }),

  resetPassword: (email: string, code: string, newPassword: string) =>
    api.publicPost<{ success: boolean }>('/api/auth/reset-password', { email, code, newPassword }),

  /* Best-effort server-side logout: revokes refresh token + clears cookie */
  logout: () => api.post<{ success: boolean }>('/api/auth/logout', {}).catch(() => ({ success: false })),
}

/* ── Tenant API ──────────────────────────────────────────────── */
export const tenantApi = {
  resolve: (slug: string) =>
    api.publicGet<{ id: string; slug: string; name: string; plan: string; logo_url: string | null; primary_color: string }>(
      `/api/tenants/resolve/${slug}`
    ),
  members:      ()            => api.get<Array<{ user_id: string; email: string; name: string; role: string; status: string }>>('/api/tenants/members'),
  update:       (data: any)   => api.patch('/api/tenants', data),
  invite:       (email: string, role: string) => api.post('/api/tenants/invite', { email, role }),
  revokeMember: (id: string)  => api.delete(`/api/tenants/members/${id}`),
  getAccess:    (userId: string) =>
    api.get<{ allowed_modules: string[] | null; role: string }>(`/api/tenants/members/${userId}/access`),
  setAccess:    (userId: string, allowed_modules: string[] | null) =>
    api.patch<{ allowed_modules: string[] | null; role: string }>(
      `/api/tenants/members/${userId}/access`, { allowed_modules }
    ),
}

/* ── Generic table API ───────────────────────────────────────── */
export function tableApi<T>(table: string) {
  return {
    list:   (params?: { orderBy?: string; order?: 'asc'|'desc'; limit?: number; offset?: number }) => {
      const qs = params ? '?' + new URLSearchParams(params as any).toString() : ''
      return api.get<T[]>(`/api/${table}${qs}`)
    },
    get:    (id: string)          => api.get<T>(`/api/${table}/${id}`),
    create: (data: Omit<T, 'id' | 'created_at' | 'tenant_id'>) =>
                                     api.post<T>(`/api/${table}`, data),
    update: (id: string, data: Partial<T>) =>
                                     api.patch<T>(`/api/${table}/${id}`, data),
    remove: (id: string)          => api.delete<{ success: boolean }>(`/api/${table}/${id}`),
  }
}

/* ── Pre-built table APIs ────────────────────────────────────── */
export const clientsApi       = tableApi('clients')
export const prospectsApi     = tableApi('prospects')
export const devisApi         = tableApi('devis')
export const facturesApi      = tableApi('factures')
export const paiementsApi     = tableApi('paiements')
export const depensesApi      = tableApi('depenses')
export const contratsApi      = tableApi('contrats')
export const produitsApi      = tableApi('produits')
export const fournisseursApi  = tableApi('fournisseurs')
export const teamApi          = tableApi('team_members')
export const domainesApi      = tableApi('domaines')
export const hebergementsApi  = tableApi('hebergements')
export const chequesRecusApi  = tableApi('cheques_recus')
export const chequesEmisApi   = tableApi('cheques_emis')
export const abonnementsApi   = tableApi('abonnements')
export const clientSubsApi    = tableApi('client_subscriptions')
export const tachesApi        = tableApi('taches')
export const autoRulesApi     = tableApi('automation_rules')
export const autoLogsApi      = tableApi('automation_logs')
export const alertsApi        = tableApi('alerts')
export const calendrierApi       = tableApi('calendrier_events')
export const bankAccountsApi     = tableApi('bank_accounts')
export const creditsDettesApi    = tableApi('credits_dettes')
export const bonsCommandeApi     = tableApi('bons_commande')
export const congesApi           = tableApi('conges')
export const salairesPaiementsApi = tableApi('salaires_paiements')
export const tacheActionsApi     = tableApi('tache_actions')
