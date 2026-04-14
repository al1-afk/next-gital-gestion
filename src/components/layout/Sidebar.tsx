import { useState } from 'react'
import { NavLink, useLocation } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  LayoutDashboard, Users, UserCheck, FileText, Receipt, FileSignature,
  CreditCard, DollarSign, TrendingUp, Globe, Server, Package, ShoppingCart,
  Repeat, BarChart3, CheckSquare, Building2, ChevronDown,
  Settings, Briefcase, Banknote, Wallet, Activity, X,
  Bot, CalendarDays,
} from 'lucide-react'
import { cn } from '@/lib/utils'

interface NavItem {
  label: string
  href:  string
  icon:  React.ElementType
  badge?: string
}

const NAV_GROUPS: { title: string; items: NavItem[] }[] = [
  {
    title: 'Principal',
    items: [
      { label: 'Tableau de bord', href: '/',          icon: LayoutDashboard },
      { label: 'CRM / Prospects', href: '/prospects', icon: UserCheck, badge: 'IA' },
      { label: 'Clients',         href: '/clients',   icon: Users },
      { label: 'Tâches',          href: '/taches',    icon: CheckSquare },
      { label: 'Calendrier',      href: '/calendrier',icon: CalendarDays },
    ],
  },
  {
    title: 'Commercial',
    items: [
      { label: 'Devis',              href: '/devis',        icon: FileText },
      { label: 'Factures',           href: '/factures',     icon: Receipt },
      { label: 'Contrats',           href: '/contrats',     icon: FileSignature },
      { label: 'Bons de commande',   href: '/bons-commande',icon: ShoppingCart },
      { label: 'Produits & Services',href: '/produits',     icon: Package },
    ],
  },
  {
    title: 'Finance',
    items: [
      { label: 'Paiements',     href: '/paiements',    icon: CreditCard },
      { label: 'Chèques reçus', href: '/cheques-recus',icon: Banknote },
      { label: 'Chèques émis',  href: '/cheques-emis', icon: Wallet },
      { label: 'Dépenses',      href: '/depenses',     icon: DollarSign },
      { label: 'Finances',      href: '/finances',     icon: TrendingUp },
      { label: 'Abonnements',   href: '/abonnements',  icon: Repeat },
    ],
  },
  {
    title: 'Ressources',
    items: [
      { label: 'Équipe',       href: '/equipe',       icon: Briefcase },
      { label: 'Fournisseurs', href: '/fournisseurs', icon: Building2 },
      { label: 'Domaines',     href: '/domaines',     icon: Globe },
      { label: 'Hébergements', href: '/hebergements', icon: Server },
    ],
  },
  {
    title: 'Analyse',
    items: [
      { label: 'Statistiques',      href: '/statistiques',  icon: BarChart3 },
      { label: "Journal d'activité",href: '/activite',      icon: Activity },
      { label: 'Conseiller IA',     href: '/conseiller-ia', icon: Bot, badge: 'IA' },
    ],
  },
]

// Persist which groups are expanded
function getInitialExpanded(): string[] {
  try {
    const stored = localStorage.getItem('sidebar-expanded-groups')
    if (stored) return JSON.parse(stored)
  } catch {}
  return NAV_GROUPS.map(g => g.title) // all open by default
}

interface SidebarProps {
  collapsed: boolean
  onToggle:  () => void
}

export default function Sidebar({ collapsed, onToggle }: SidebarProps) {
  const location = useLocation()
  const [expandedGroups, setExpandedGroups] = useState<string[]>(getInitialExpanded)

  const toggleGroup = (title: string) => {
    setExpandedGroups(prev => {
      const next = prev.includes(title)
        ? prev.filter(g => g !== title)
        : [...prev, title]
      try { localStorage.setItem('sidebar-expanded-groups', JSON.stringify(next)) } catch {}
      return next
    })
  }

  return (
    <aside
      className={cn(
        'fixed left-0 top-0 h-screen z-40 flex flex-col transition-all duration-300',
        'border-r',
        // Dark mode — brand dark
        'dark:bg-[#020617] dark:border-slate-800/80',
        // Light mode — spec: #F8F9FA bg, #E2E8F0 border
        'light:bg-[#F8F9FA] light:border-[#E2E8F0]',
        collapsed ? 'w-16' : 'w-64'
      )}
    >
      {/* ── Logo ── */}
      <div className={cn(
        'flex items-center h-16 px-4 flex-shrink-0 border-b',
        'dark:border-slate-800/80 light:border-[#E2E8F0]',
        collapsed ? 'justify-center' : 'justify-between'
      )}>
        {!collapsed && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="flex items-center gap-2.5 min-w-0"
          >
            <div className="w-8 h-8 rounded-lg bg-[#3a526b] flex items-center justify-center flex-shrink-0 shadow-sm">
              <span className="text-white font-bold text-sm">N</span>
            </div>
            <span className="font-semibold text-base tracking-tight truncate dark:text-white light:text-[#1e293b]">
              NextGital
            </span>
          </motion.div>
        )}
        {collapsed && (
          <div className="w-8 h-8 rounded-lg bg-[#3a526b] flex items-center justify-center shadow-sm">
            <span className="text-white font-bold text-sm">N</span>
          </div>
        )}
        {!collapsed && (
          <button
            onClick={onToggle}
            className={cn(
              'p-1.5 rounded-lg transition-colors flex-shrink-0',
              'dark:text-slate-500 dark:hover:text-white dark:hover:bg-slate-800',
              'light:text-[#888780] light:hover:text-[#444441] light:hover:bg-[#E2E8F0]'
            )}
            title="Réduire le menu"
          >
            <X className="w-4 h-4" />
          </button>
        )}
      </div>

      {/* ── Navigation ── */}
      <div className="flex-1 overflow-y-auto py-3 px-2 space-y-0.5">
        {NAV_GROUPS.map(group => (
          <div key={group.title} className="mb-1">
            {/* Section header */}
            {!collapsed && (
              <button
                onClick={() => toggleGroup(group.title)}
                className={cn(
                  'w-full flex items-center justify-between px-2 py-1.5 mb-0.5',
                  'text-[11px] font-semibold uppercase tracking-[0.08em]',
                  'transition-colors duration-150 select-none rounded',
                  'dark:text-slate-500 dark:hover:text-slate-300',
                  'light:text-[#5F5E5A] light:hover:text-[#2C2C2A] light:hover:bg-[#E2E8F0]'
                )}
              >
                {group.title}
                <motion.span
                  animate={{ rotate: expandedGroups.includes(group.title) ? 0 : -90 }}
                  transition={{ duration: 0.2 }}
                >
                  <ChevronDown className="w-3 h-3" />
                </motion.span>
              </button>
            )}

            <AnimatePresence initial={false}>
              {(collapsed || expandedGroups.includes(group.title)) && (
                <motion.div
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: 'auto', opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }}
                  transition={{ duration: 0.2, ease: 'easeInOut' }}
                  className="overflow-hidden"
                >
                  {group.items.map(item => {
                    const isActive = item.href === '/'
                      ? location.pathname === '/'
                      : location.pathname.startsWith(item.href)
                    return (
                      <NavLink
                        key={item.href}
                        to={item.href}
                        className={cn(
                          'sidebar-item',
                          isActive && 'active',
                          collapsed && 'justify-center px-0'
                        )}
                        title={collapsed ? item.label : undefined}
                      >
                        <item.icon className={cn('flex-shrink-0', collapsed ? 'w-5 h-5' : 'w-4 h-4')} />
                        {!collapsed && (
                          <>
                            <span className="flex-1 truncate">{item.label}</span>
                            {item.badge === 'IA' && (
                              <span
                                className="px-1.5 py-0.5 rounded text-[10px] font-bold leading-none bg-[#EEEDFE] text-[#3C3489] border border-[#A79FF4] dark:bg-purple-950/60 dark:text-purple-300 dark:border-purple-700/50"
                                title="Powered by AI"
                              >
                                IA ✦
                              </span>
                            )}
                          </>
                        )}
                      </NavLink>
                    )
                  })}
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        ))}
      </div>

      {/* ── Footer ── */}
      <div className={cn(
        'border-t p-2 flex-shrink-0',
        'dark:border-slate-800/80 light:border-[#E2E8F0]'
      )}>
        <NavLink
          to="/parametres"
          className={cn('sidebar-item', collapsed && 'justify-center px-0')}
          title={collapsed ? 'Paramètres' : undefined}
        >
          <Settings className={cn('flex-shrink-0', collapsed ? 'w-5 h-5' : 'w-4 h-4')} />
          {!collapsed && <span>Paramètres</span>}
        </NavLink>
      </div>
    </aside>
  )
}
