import { useState } from 'react'
import { Outlet, useLocation } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { X } from 'lucide-react'
import { cn } from '@/lib/utils'
import Sidebar from './Sidebar'
import Header  from './Header'
import GlobalSearch from '@/components/GlobalSearch'
import Onboarding, { isOnboardingDone } from '@/components/Onboarding'
import { useRealtime } from '@/hooks/useRealtime'
import { useKeyboardShortcuts } from '@/hooks/useKeyboardShortcuts'
import { useNetworkStatus } from '@/hooks/useNetworkStatus'
import { useOfflineSync } from '@/hooks/useOfflineSync'
import PwaInstallBanner from '@/components/PwaInstallBanner'
import ShortcutsModal from '@/components/ShortcutsModal'

function getSavedCollapsed(): boolean {
  try { return localStorage.getItem('sidebar-collapsed') === 'true' }
  catch { return false }
}

export default function AppLayout() {
  const location  = useLocation()
  const [collapsed,      setCollapsed]      = useState(getSavedCollapsed)
  const [mobileOpen,     setMobileOpen]     = useState(false)
  const [showOnboarding, setShowOnboarding] = useState(() => !isOnboardingDone())

  useRealtime()
  useKeyboardShortcuts()
  useNetworkStatus()
  useOfflineSync()

  const handleToggle = () => {
    setCollapsed(prev => {
      const next = !prev
      try { localStorage.setItem('sidebar-collapsed', String(next)) } catch {}
      return next
    })
  }

  return (
    <div className="min-h-screen bg-background">
      {/* ── Desktop sidebar ── */}
      <div className="hidden md:block">
        <Sidebar collapsed={collapsed} onToggle={handleToggle} />
      </div>

      {/* ── Mobile sidebar drawer ── */}
      <AnimatePresence>
        {mobileOpen && (
          <>
            <motion.div
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              className="fixed inset-0 z-40 bg-black/60 md:hidden"
              onClick={() => setMobileOpen(false)}
            />
            <motion.div
              initial={{ x: -280 }} animate={{ x: 0 }} exit={{ x: -280 }}
              transition={{ type: 'spring', stiffness: 320, damping: 32 }}
              className="fixed left-0 top-0 h-screen z-50 md:hidden"
            >
              <Sidebar collapsed={false} onToggle={() => setMobileOpen(false)} />
              <button
                onClick={() => setMobileOpen(false)}
                className="absolute top-4 right-4 p-1.5 rounded-lg bg-slate-800 text-slate-400 hover:text-white"
              >
                <X className="w-4 h-4" />
              </button>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      <Header
        onMenuToggle={() => {
          if (window.innerWidth < 768) setMobileOpen(v => !v)
          else handleToggle()
        }}
        collapsed={collapsed}
      />

      {/* Global search palette — mounted once, listens to Cmd+K globally */}
      <GlobalSearch />

      {/* First-time onboarding wizard */}
      <AnimatePresence>
        {showOnboarding && <Onboarding onClose={() => setShowOnboarding(false)} />}
      </AnimatePresence>

      {/* PWA install prompt */}
      <PwaInstallBanner />
      {/* Keyboard shortcuts help modal */}
      <ShortcutsModal />

      <main
        className={cn(
          'pt-16 transition-all duration-300 min-h-screen',
          'pl-0 md:pl-64',
          collapsed && 'md:pl-16',
        )}
      >
        <motion.div
          key={location.pathname}
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.22, ease: 'easeOut' }}
          className="p-4 md:p-8"
        >
          <Outlet />
        </motion.div>
      </main>
    </div>
  )
}
