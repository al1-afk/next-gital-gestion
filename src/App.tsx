import { lazy, Suspense } from 'react'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { Toaster } from 'sonner'
import AppLayout      from '@/components/layout/AppLayout'
import ProtectedRoute from '@/components/auth/ProtectedRoute'
import ErrorBoundary  from '@/components/ErrorBoundary'
import { ThemeProvider }  from '@/contexts/ThemeContext'
import { TenantProvider } from '@/contexts/TenantContext'

// Lazy load all pages for code splitting & performance
const Dashboard      = lazy(() => import('@/pages/Dashboard'))
const Auth           = lazy(() => import('@/pages/Auth'))
const Prospects      = lazy(() => import('@/pages/Prospects'))
const Clients        = lazy(() => import('@/pages/Clients'))
const ClientDetail   = lazy(() => import('@/pages/ClientDetail'))
const Devis          = lazy(() => import('@/pages/Devis'))
const DevisPreview   = lazy(() => import('@/pages/DevisPreview'))
const Factures       = lazy(() => import('@/pages/Factures'))
const Contrats       = lazy(() => import('@/pages/Contrats'))
const Paiements      = lazy(() => import('@/pages/Paiements'))
const ChequesRecus   = lazy(() => import('@/pages/ChequesRecus'))
const ChequesEmis    = lazy(() => import('@/pages/ChequesEmis'))
const Depenses       = lazy(() => import('@/pages/Depenses'))
const Finances       = lazy(() => import('@/pages/Finances'))
const Abonnements    = lazy(() => import('@/pages/Abonnements'))
const Equipe         = lazy(() => import('@/pages/Equipe'))
const Fournisseurs   = lazy(() => import('@/pages/Fournisseurs'))
const Domaines       = lazy(() => import('@/pages/Domaines'))
const Hebergements   = lazy(() => import('@/pages/Hebergements'))
const Vehicules      = lazy(() => import('@/pages/Vehicules'))
const Produits       = lazy(() => import('@/pages/Produits'))
const ProduitsStock  = lazy(() => import('@/pages/ProduitsStock'))
const BonsCommande   = lazy(() => import('@/pages/BonsCommande'))
const Statistiques   = lazy(() => import('@/pages/Statistiques'))
const ActivityLogs   = lazy(() => import('@/pages/ActivityLogs'))
const ConseillerIA   = lazy(() => import('@/pages/ConseillerIA'))
const Taches         = lazy(() => import('@/pages/Taches'))
const Calendrier     = lazy(() => import('@/pages/Calendrier'))
const Parametres       = lazy(() => import('@/pages/Parametres'))
const Automatisations     = lazy(() => import('@/pages/Automatisations'))
const AbonnementsClients  = lazy(() => import('@/pages/AbonnementsClients'))
const Integrations        = lazy(() => import('@/pages/Integrations'))
const Rapports            = lazy(() => import('@/pages/Rapports'))
const Landing             = lazy(() => import('@/pages/Landing'))
const ComingSoon          = lazy(() => import('@/pages/ComingSoon'))

import { queryClient } from '@/lib/queryClient'

function PageLoader() {
  return (
    <div className="flex items-center justify-center min-h-[400px]">
      <div className="flex items-center gap-3">
        <div className="w-8 h-8 rounded-full border-2 border-blue-500 border-t-transparent animate-spin" />
        <span className="text-slate-400 text-sm">Chargement...</span>
      </div>
    </div>
  )
}

export default function App() {
  return (
    <ThemeProvider>
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <ErrorBoundary>
        <Suspense fallback={<PageLoader />}>
          <Routes>
            {/* ── Public routes ─────────────────────────────────── */}
            <Route path="/"     element={<Landing />} />
            <Route path="/auth" element={<Auth />} />

            {/* ── Tenant workspace: gestiq.com/:tenantSlug/* ─────── */}
            <Route path="/:tenantSlug" element={
              <TenantProvider>
                <ProtectedRoute><AppLayout /></ProtectedRoute>
              </TenantProvider>
            }>
              <Route index                              element={<Dashboard />} />
              <Route path="prospects"                  element={<Prospects />} />
              <Route path="clients"                    element={<Clients />} />
              <Route path="clients/:id"                element={<ClientDetail />} />
              <Route path="taches"                     element={<Taches />} />
              <Route path="calendrier"                 element={<Calendrier />} />
              <Route path="devis"                      element={<Devis />} />
              <Route path="devis/:id/preview"          element={<DevisPreview />} />
              {/* Backwards-compat: old shared links missing the /devis/ segment */}
              <Route path=":id/preview"                element={<DevisPreview />} />
              <Route path="factures"                   element={<Factures />} />
              <Route path="contrats"                   element={<Contrats />} />
              <Route path="bons-commande"              element={<BonsCommande />} />
              <Route path="produits"                   element={<Produits />} />
              <Route path="produits-stock"             element={<ProduitsStock />} />
              <Route path="paiements"                  element={<Paiements />} />
              <Route path="cheques-recus"              element={<ChequesRecus />} />
              <Route path="cheques-emis"               element={<ChequesEmis />} />
              <Route path="depenses"                   element={<Depenses />} />
              <Route path="finances"                   element={<Finances />} />
              <Route path="abonnements"                element={<Abonnements />} />
              <Route path="abonnements-clients"        element={<AbonnementsClients />} />
              <Route path="integrations"               element={<Integrations />} />
              <Route path="equipe"                     element={<Equipe />} />
              <Route path="fournisseurs"               element={<Fournisseurs />} />
              <Route path="domaines"                   element={<Domaines />} />
              <Route path="hebergements"               element={<Hebergements />} />
              <Route path="vehicules"                  element={<Vehicules />} />
              <Route path="statistiques"               element={<Statistiques />} />
              <Route path="activite"                   element={<ActivityLogs />} />
              <Route path="conseiller-ia"              element={<ConseillerIA />} />
              <Route path="parametres"                 element={<Parametres />} />
              <Route path="automatisations"            element={<Automatisations />} />
              <Route path="rapports"                   element={<Rapports />} />
              <Route path="bientot"                    element={<ComingSoon />} />
              <Route path="*"                          element={<Navigate to="" replace />} />
            </Route>

            {/* ── Catch-all ─────────────────────────────────────── */}
            <Route path="*" element={<Navigate to="/auth" replace />} />
          </Routes>
        </Suspense>
        </ErrorBoundary>
      </BrowserRouter>

      <Toaster
        position="bottom-right"
        toastOptions={{
          style: {
            background: '#0f172a',
            border: '1px solid #1e293b',
            color: '#f1f5f9',
            fontSize: '14px',
          },
        }}
      />
    </QueryClientProvider>
    </ThemeProvider>
  )
}
