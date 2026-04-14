import { useState } from 'react'
import { useLocation } from 'react-router-dom'
import { motion } from 'framer-motion'
import {
  Menu, Search, Bell, ChevronRight, User, LogOut, Settings,
} from 'lucide-react'
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem,
  DropdownMenuSeparator, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import ThemeToggle from '@/components/ui/ThemeToggle'
import { cn } from '@/lib/utils'

const BREADCRUMB_MAP: Record<string, string> = {
  '/':             'Tableau de bord',
  '/prospects':    'CRM / Prospects',
  '/clients':      'Clients',
  '/taches':       'Tâches',
  '/calendrier':   'Calendrier',
  '/devis':        'Devis',
  '/factures':     'Factures',
  '/contrats':     'Contrats',
  '/bons-commande':'Bons de commande',
  '/produits':     'Produits & Services',
  '/paiements':    'Paiements',
  '/cheques-recus':'Chèques reçus',
  '/cheques-emis': 'Chèques émis',
  '/depenses':     'Dépenses',
  '/finances':     'Finances',
  '/abonnements':  'Abonnements',
  '/equipe':       'Équipe',
  '/fournisseurs': 'Fournisseurs',
  '/domaines':     'Domaines',
  '/hebergements': 'Hébergements',
  '/statistiques': 'Statistiques',
  '/activite':     "Journal d'activité",
  '/conseiller-ia':'Conseiller IA',
  '/parametres':   'Paramètres',
}

interface HeaderProps {
  onMenuToggle: () => void
  collapsed:    boolean
}

export default function Header({ onMenuToggle, collapsed }: HeaderProps) {
  const location = useLocation()
  const [searchOpen,  setSearchOpen]  = useState(false)
  const [searchQuery, setSearchQuery] = useState('')

  const pathname    = location.pathname
  const currentPage = BREADCRUMB_MAP[pathname] || pathname.split('/').filter(Boolean)[0]?.replace(/-/g, ' ') || 'Accueil'

  const iconBtn = cn(
    'h-9 w-9 flex items-center justify-center rounded-lg transition-colors duration-150',
    'text-muted-foreground hover:text-foreground',
    'dark:hover:bg-slate-800 light:hover:bg-[#F1F5F9]'
  )

  return (
    <header
      className={cn(
        'fixed top-0 right-0 h-16 z-30 flex items-center justify-between px-6',
        'backdrop-blur-sm border-b transition-all duration-300',
        'dark:border-slate-800/80 dark:bg-[#020617]/95',
        'light:border-[#E2E8F0] light:bg-white/95',
        collapsed ? 'left-16' : 'left-64'
      )}
    >
      {/* ── Left ── */}
      <div className="flex items-center gap-3">
        <button onClick={onMenuToggle} className={iconBtn} aria-label="Menu">
          <Menu className="w-5 h-5" />
        </button>

        <nav className="flex items-center gap-1.5 text-sm">
          <span className="text-muted-foreground">NextGital</span>
          <ChevronRight className="w-3.5 h-3.5 text-muted-foreground/50" />
          <span className="font-medium text-foreground capitalize">{currentPage}</span>
        </nav>
      </div>

      {/* ── Right ── */}
      <div className="flex items-center gap-1">
        {/* Search */}
        <div className="relative">
          {searchOpen ? (
            <motion.input
              initial={{ width: 0, opacity: 0 }}
              animate={{ width: 240, opacity: 1 }}
              exit={{ width: 0, opacity: 0 }}
              autoFocus
              value={searchQuery}
              onChange={e => setSearchQuery(e.target.value)}
              onBlur={() => { setSearchOpen(false); setSearchQuery('') }}
              placeholder="Rechercher…"
              className={cn(
                'h-9 rounded-lg px-3 text-sm outline-none transition-all',
                'border border-border bg-[var(--surface-input)] text-foreground placeholder:text-muted-foreground',
                'focus:border-[#378ADD] focus:shadow-[0_0_0_2px_rgba(55,138,221,0.15)]'
              )}
            />
          ) : (
            <button onClick={() => setSearchOpen(true)} className={iconBtn} aria-label="Rechercher">
              <Search className="w-4 h-4" />
            </button>
          )}
        </div>

        {/* Theme toggle */}
        <ThemeToggle />

        {/* Notifications */}
        <button className={cn(iconBtn, 'relative')} aria-label="Notifications">
          <Bell className="w-4 h-4" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-[#378ADD] rounded-full" />
        </button>

        {/* Divider */}
        <div className="w-px h-6 bg-border mx-1" />

        {/* User menu */}
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <button className="flex items-center gap-2.5 hover:opacity-80 transition-opacity" aria-label="Menu utilisateur">
              <div className="w-8 h-8 rounded-full bg-[#3a526b] flex items-center justify-center flex-shrink-0">
                <span className="text-white text-xs font-bold">NG</span>
              </div>
              <div className="text-left hidden sm:block">
                <p className="text-sm font-medium text-foreground leading-none">NextGital</p>
                <p className="text-xs text-muted-foreground mt-0.5">Admin</p>
              </div>
            </button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-48">
            <DropdownMenuItem className="cursor-pointer gap-2">
              <User className="w-4 h-4" /> Profil
            </DropdownMenuItem>
            <DropdownMenuItem className="cursor-pointer gap-2">
              <Settings className="w-4 h-4" /> Paramètres
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem className="cursor-pointer gap-2 text-[#A32D2D] dark:text-red-400 focus:text-[#A32D2D] focus:bg-[#FCEBEB] dark:focus:bg-red-950/50">
              <LogOut className="w-4 h-4" /> Déconnexion
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  )
}
