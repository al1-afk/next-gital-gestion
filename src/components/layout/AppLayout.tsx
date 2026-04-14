import { useState } from 'react'
import { Outlet, useLocation } from 'react-router-dom'
import { motion } from 'framer-motion'
import { cn } from '@/lib/utils'
import Sidebar from './Sidebar'
import Header from './Header'

function getSavedCollapsed(): boolean {
  try { return localStorage.getItem('sidebar-collapsed') === 'true' }
  catch { return false }
}

export default function AppLayout() {
  const location = useLocation()
  const [collapsed, setCollapsed] = useState(getSavedCollapsed)

  const handleToggle = () => {
    setCollapsed(prev => {
      const next = !prev
      try { localStorage.setItem('sidebar-collapsed', String(next)) } catch {}
      return next
    })
  }

  return (
    <div className="min-h-screen bg-background">
      <Sidebar collapsed={collapsed} onToggle={handleToggle} />
      <Header onMenuToggle={handleToggle} collapsed={collapsed} />

      <main
        className={cn(
          'pt-16 transition-all duration-300 min-h-screen',
          collapsed ? 'pl-16' : 'pl-64'
        )}
      >
        <motion.div
          key={location.pathname}
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.22, ease: 'easeOut' }}
          className="p-8"
        >
          <Outlet />
        </motion.div>
      </main>
    </div>
  )
}
