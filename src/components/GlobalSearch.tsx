import { useState, useEffect, useRef, useMemo } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Search, X, Users, UserCheck, FileText, Receipt,
  DollarSign, Package, Globe, Server, Briefcase,
  ArrowRight, Hash, Clock,
} from 'lucide-react'
import { useClients }   from '@/hooks/useClients'
import { useProspects } from '@/hooks/useProspects'
import { useFactures }  from '@/hooks/useFactures'
import { useDevis }     from '@/hooks/useDevis'
import { formatCurrency } from '@/lib/utils'
import { cn } from '@/lib/utils'

interface SearchResult {
  id:       string
  type:     string
  label:    string
  sub?:     string
  href:     string
  icon:     React.ElementType
  color:    string
}

const STATIC_PAGES = [
  { id: 'p1',  type: 'Page', label: 'Tableau de bord',       href: '/',                   icon: Hash,     color: 'text-blue-500'    },
  { id: 'p2',  type: 'Page', label: 'Prospects / CRM',        href: '/prospects',          icon: UserCheck,color: 'text-violet-500'  },
  { id: 'p3',  type: 'Page', label: 'Clients',                href: '/clients',            icon: Users,    color: 'text-emerald-500' },
  { id: 'p4',  type: 'Page', label: 'Factures',               href: '/factures',           icon: Receipt,  color: 'text-amber-500'   },
  { id: 'p5',  type: 'Page', label: 'Devis',                  href: '/devis',              icon: FileText, color: 'text-blue-500'    },
  { id: 'p6',  type: 'Page', label: 'Paiements',              href: '/paiements',          icon: DollarSign,color:'text-emerald-500' },
  { id: 'p7',  type: 'Page', label: 'Abonnements Clients',    href: '/abonnements-clients',icon: Clock,    color: 'text-violet-500'  },
  { id: 'p8',  type: 'Page', label: 'Équipe & Accès',         href: '/equipe',             icon: Briefcase,color: 'text-slate-500'   },
  { id: 'p9',  type: 'Page', label: 'Statistiques',           href: '/statistiques',       icon: Hash,     color: 'text-blue-500'    },
  { id: 'p10', type: 'Page', label: 'Automatisations',        href: '/automatisations',    icon: Hash,     color: 'text-amber-500'   },
  { id: 'p11', type: 'Page', label: 'Intégrations',           href: '/integrations',       icon: Hash,     color: 'text-slate-500'   },
  { id: 'p12', type: 'Page', label: 'Produits & Services',    href: '/produits',           icon: Package,  color: 'text-teal-500'    },
  { id: 'p13', type: 'Page', label: 'Domaines',               href: '/domaines',           icon: Globe,    color: 'text-slate-500'   },
  { id: 'p14', type: 'Page', label: 'Hébergements',           href: '/hebergements',       icon: Server,   color: 'text-slate-500'   },
  { id: 'p15', type: 'Page', label: 'Paramètres',             href: '/parametres',         icon: Hash,     color: 'text-slate-500'   },
]

export default function GlobalSearch() {
  const [open,  setOpen]  = useState(false)
  const [query, setQuery] = useState('')
  const [idx,   setIdx]   = useState(0)
  const inputRef  = useRef<HTMLInputElement>(null)
  const navigate  = useNavigate()

  const { data: clients   = [] } = useClients()
  const { data: prospects = [] } = useProspects()
  const { data: factures  = [] } = useFactures()
  const { data: devis     = [] } = useDevis()

  // Cmd+K / Ctrl+K
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault()
        setOpen(v => !v)
        setQuery('')
      }
      if (e.key === 'Escape') setOpen(false)
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [])

  useEffect(() => {
    if (open) setTimeout(() => inputRef.current?.focus(), 50)
  }, [open])

  const results = useMemo<SearchResult[]>(() => {
    const q = query.trim().toLowerCase()
    if (!q) return STATIC_PAGES.slice(0, 6) as SearchResult[]

    const out: SearchResult[] = []

    // Pages
    STATIC_PAGES.forEach(p => {
      if (p.label.toLowerCase().includes(q)) out.push(p as SearchResult)
    })

    // Clients
    clients.filter(c =>
      [c.nom, c.email, c.entreprise, c.telephone].some(f => f?.toLowerCase().includes(q))
    ).slice(0, 5).forEach(c => out.push({
      id:    `c-${c.id}`,
      type:  'Client',
      label: c.nom,
      sub:   c.entreprise || c.email || '',
      href:  `/clients/${c.id}`,
      icon:  Users,
      color: 'text-emerald-500',
    }))

    // Prospects
    prospects.filter(p =>
      [p.nom, p.email, p.entreprise].some(f => f?.toLowerCase().includes(q))
    ).slice(0, 5).forEach(p => out.push({
      id:    `pr-${p.id}`,
      type:  'Prospect',
      label: p.nom,
      sub:   p.entreprise || p.statut,
      href:  '/prospects',
      icon:  UserCheck,
      color: 'text-violet-500',
    }))

    // Factures
    factures.filter(f =>
      [f.numero, (f as any).client_nom].some(x => x?.toLowerCase().includes(q))
    ).slice(0, 4).forEach(f => out.push({
      id:    `f-${f.id}`,
      type:  'Facture',
      label: f.numero,
      sub:   formatCurrency(f.montant_ttc) + ' · ' + f.statut,
      href:  '/factures',
      icon:  Receipt,
      color: 'text-amber-500',
    }))

    // Devis
    devis.filter(d =>
      [d.numero, (d as any).client_nom].some(x => x?.toLowerCase().includes(q))
    ).slice(0, 4).forEach(d => out.push({
      id:    `d-${d.id}`,
      type:  'Devis',
      label: d.numero,
      sub:   formatCurrency(d.montant_ttc) + ' · ' + d.statut,
      href:  '/devis',
      icon:  FileText,
      color: 'text-blue-500',
    }))

    return out.slice(0, 12)
  }, [query, clients, prospects, factures, devis])

  useEffect(() => setIdx(0), [results])

  const go = (href: string) => {
    setOpen(false)
    setQuery('')
    navigate(href)
  }

  const handleKey = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowDown') { e.preventDefault(); setIdx(i => Math.min(i + 1, results.length - 1)) }
    if (e.key === 'ArrowUp')   { e.preventDefault(); setIdx(i => Math.max(i - 1, 0)) }
    if (e.key === 'Enter' && results[idx]) go(results[idx].href)
  }

  const grouped = results.reduce<Record<string, SearchResult[]>>((acc, r) => {
    ;(acc[r.type] = acc[r.type] || []).push(r)
    return acc
  }, {})

  return (
    <>
      {/* Trigger button in header — emitted separately via event */}
      <AnimatePresence>
        {open && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm"
              onClick={() => setOpen(false)}
            />

            {/* Modal */}
            <motion.div
              initial={{ opacity: 0, scale: 0.96, y: -12 }}
              animate={{ opacity: 1, scale: 1,    y: 0    }}
              exit={{    opacity: 0, scale: 0.96, y: -12  }}
              transition={{ duration: 0.15 }}
              className="fixed top-20 left-1/2 -translate-x-1/2 z-50 w-full max-w-xl"
            >
              <div className="bg-[#0f1829] border border-slate-700/60 rounded-2xl shadow-2xl overflow-hidden">
                {/* Search input */}
                <div className="flex items-center gap-3 px-4 py-3 border-b border-slate-700/60">
                  <Search className="w-5 h-5 text-slate-400 flex-shrink-0" />
                  <input
                    ref={inputRef}
                    value={query}
                    onChange={e => setQuery(e.target.value)}
                    onKeyDown={handleKey}
                    placeholder="Rechercher clients, factures, pages..."
                    className="flex-1 bg-transparent text-white placeholder-slate-500 outline-none text-sm"
                  />
                  {query && (
                    <button onClick={() => setQuery('')} className="text-slate-500 hover:text-slate-300">
                      <X className="w-4 h-4" />
                    </button>
                  )}
                  <kbd className="hidden sm:flex items-center gap-0.5 px-1.5 py-0.5 rounded bg-slate-800 border border-slate-700 text-slate-400 text-[10px] font-mono">
                    ESC
                  </kbd>
                </div>

                {/* Results */}
                <div className="max-h-80 overflow-y-auto py-2">
                  {results.length === 0 ? (
                    <p className="text-center text-slate-500 text-sm py-8">Aucun résultat pour « {query} »</p>
                  ) : (
                    Object.entries(grouped).map(([type, items]) => (
                      <div key={type}>
                        <p className="px-4 py-1.5 text-[10px] font-bold uppercase tracking-widest text-slate-600">{type}</p>
                        {items.map(r => {
                          const flatIdx = results.indexOf(r)
                          return (
                            <button
                              key={r.id}
                              onClick={() => go(r.href)}
                              onMouseEnter={() => setIdx(flatIdx)}
                              className={cn(
                                'w-full flex items-center gap-3 px-4 py-2.5 text-left transition-colors',
                                flatIdx === idx ? 'bg-blue-600/20' : 'hover:bg-slate-800/50',
                              )}
                            >
                              <div className={`w-7 h-7 rounded-lg bg-slate-800 flex items-center justify-center flex-shrink-0`}>
                                <r.icon className={`w-3.5 h-3.5 ${r.color}`} />
                              </div>
                              <div className="flex-1 min-w-0">
                                <p className="text-sm text-white truncate">{r.label}</p>
                                {r.sub && <p className="text-xs text-slate-500 truncate">{r.sub}</p>}
                              </div>
                              {flatIdx === idx && <ArrowRight className="w-3.5 h-3.5 text-blue-400 flex-shrink-0" />}
                            </button>
                          )
                        })}
                      </div>
                    ))
                  )}
                </div>

                {/* Footer */}
                <div className="px-4 py-2 border-t border-slate-700/60 flex items-center gap-4 text-[11px] text-slate-600">
                  <span>↑↓ naviguer</span>
                  <span>↵ ouvrir</span>
                  <span>Esc fermer</span>
                </div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  )
}

// Export trigger function for Header button
export function openGlobalSearch() {
  window.dispatchEvent(new KeyboardEvent('keydown', { key: 'k', metaKey: true, bubbles: true }))
}
