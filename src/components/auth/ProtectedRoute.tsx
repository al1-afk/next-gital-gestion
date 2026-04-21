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
  const { loading, isAuthorized } = useAuth()
  const location   = useLocation()
  const { tenantSlug } = useParams<{ tenantSlug: string }>()

  if (loading) return <FullPageLoader />
  if (!isAuthorized) {
    if (tenantSlug) sessionStorage.setItem('gestiq_tenant_slug', tenantSlug)
    return <Navigate to={`/auth${tenantSlug ? `?tenant=${tenantSlug}` : ''}`} state={{ from: location }} replace />
  }
  return <>{children}</>
}
