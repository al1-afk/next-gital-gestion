import { Navigate, useLocation, useParams } from 'react-router-dom'
import { useAuth } from '@/hooks/useAuth'

function FullPageLoader() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-[#060d1c]">
      <div className="flex flex-col items-center gap-4">
        <div className="w-10 h-10 rounded-full border-2 border-blue-500 border-t-transparent animate-spin" />
        <span className="text-slate-400 text-sm">Vérification de session...</span>
      </div>
    </div>
  )
}

export default function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { loading, isAuthorized, tenantSlug: authTenantSlug } = useAuth()
  const location   = useLocation()
  const { tenantSlug: urlTenantSlug } = useParams<{ tenantSlug: string }>()

  if (loading) return <FullPageLoader />

  if (!isAuthorized) {
    if (urlTenantSlug) sessionStorage.setItem('gestiq_tenant_slug', urlTenantSlug)
    return (
      <Navigate
        to={`/auth${urlTenantSlug ? `?tenant=${urlTenantSlug}` : ''}`}
        state={{ from: location }}
        replace
      />
    )
  }

  /* Guard: the workspace slug in the URL must match the one baked
     into the current session (derived from the JWT `tenantId`).
     Mismatch would cause the UI to render tenant B's chrome while
     the API returns tenant A's data — the exact symptom of the
     "all users see the same data" bug we are fixing. Redirect to
     the correct workspace silently. */
  if (urlTenantSlug && authTenantSlug && urlTenantSlug !== authTenantSlug) {
    const suffix = location.pathname.replace(/^\/[^/]+/, '')
    return <Navigate to={`/${authTenantSlug}${suffix}`} replace />
  }

  return <>{children}</>
}
