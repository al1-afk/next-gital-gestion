import { useMemo, useState } from 'react'
import { Search, Activity, User, FileText, Receipt, UserCheck, DollarSign, Filter } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { useFactures } from '@/hooks/useFactures'
import { useProspects } from '@/hooks/useProspects'
import { useDevis } from '@/hooks/useDevis'
import { formatDate } from '@/lib/utils'
import {
  DateRangeFilter, DEFAULT_RANGE, makeDatePredicate, type DateRange,
} from '@/components/ui/DateRangeFilter'

const ICONS: Record<string, React.ElementType> = {
  prospect: UserCheck,
  devis:    FileText,
  facture:  Receipt,
  paiement: DollarSign,
  client:   User,
}

const MODULE_COLORS: Record<string, string> = {
  prospect: 'bg-blue-400',
  devis:    'bg-violet-400',
  facture:  'bg-amber-400',
  paiement: 'bg-emerald-400',
  client:   'bg-purple-400',
}

interface LogEntry {
  id:     string
  module: string
  action: string
  detail: string
  date:   string
  color:  string
}

function formatTs(iso: string) {
  try {
    const d = new Date(iso)
    return d.toLocaleString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' })
  } catch { return iso }
}

export default function ActivityLogs() {
  const { data: factures = [] } = useFactures()
  const { data: prospects = [] } = useProspects()
  const { data: devis = [] }    = useDevis()
  const [search, setSearch] = useState('')
  const [filterModule, setFilterModule] = useState('all')
  const [dateRange, setDateRange] = useState<DateRange>(DEFAULT_RANGE)
  const dateMatch = useMemo(() => makeDatePredicate(dateRange), [dateRange])

  const logs = useMemo<LogEntry[]>(() => {
    const entries: LogEntry[] = []

    for (const f of factures) {
      if (f.statut === 'payee') {
        entries.push({
          id:     `pay-${f.id}`,
          module: 'paiement',
          action: 'Paiement reçu',
          detail: `${f.numero} — ${f.client_nom ?? 'Client'} · ${f.montant_paye.toLocaleString('fr-MA')} MAD`,
          date:   f.created_at,
          color:  'emerald',
        })
      }
      entries.push({
        id:     `fac-${f.id}`,
        module: 'facture',
        action: f.statut === 'brouillon' ? 'Facture créée (brouillon)' :
                f.statut === 'impayee'   ? 'Facture impayée' :
                f.statut === 'annulee'   ? 'Facture annulée' :
                                           'Facture émise',
        detail: `${f.numero} — ${f.client_nom ?? 'Client'} · ${f.montant_ttc.toLocaleString('fr-MA')} MAD`,
        date:   f.created_at,
        color:  f.statut === 'payee' ? 'emerald' : f.statut === 'impayee' ? 'red' : 'amber',
      })
    }

    for (const p of prospects) {
      entries.push({
        id:     `pro-${p.id}`,
        module: 'prospect',
        action: p.statut === 'gagne'  ? 'Prospect converti' :
                p.statut === 'perdu'  ? 'Prospect perdu' :
                p.statut === 'nouveau' ? 'Prospect ajouté' :
                                         'Statut prospect mis à jour',
        detail: `${p.nom}${p.entreprise ? ` — ${p.entreprise}` : ''}${p.valeur_estimee ? ` · ${p.valeur_estimee.toLocaleString('fr-MA')} MAD` : ''}`,
        date:   p.created_at,
        color:  p.statut === 'gagne' ? 'green' : p.statut === 'perdu' ? 'red' : 'blue',
      })
    }

    for (const d of devis) {
      entries.push({
        id:     `dev-${d.id}`,
        module: 'devis',
        action: d.statut === 'accepte' ? 'Devis accepté' :
                d.statut === 'refuse'  ? 'Devis refusé' :
                d.statut === 'envoye'  ? 'Devis envoyé' :
                                          'Devis créé',
        detail: `${d.numero} — ${d.client_nom ?? 'Client'} · ${d.montant_ttc.toLocaleString('fr-MA')} MAD`,
        date:   d.created_at,
        color:  d.statut === 'accepte' ? 'green' : d.statut === 'refuse' ? 'red' : 'violet',
      })
    }

    return entries
      .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
      .filter((e, i, arr) => arr.findIndex(x => x.id === e.id) === i)
  }, [factures, prospects, devis])

  const filtered = useMemo(() =>
    logs.filter(l => {
      const ms = !search || [l.action, l.detail, l.module].some(x => x.toLowerCase().includes(search.toLowerCase()))
      const fm = filterModule === 'all' || l.module === filterModule
      const md = dateMatch(l.date)
      return ms && fm && md
    })
  , [logs, search, filterModule, dateMatch])

  const COLOR_DOT: Record<string, string> = {
    emerald: 'bg-emerald-400', blue: 'bg-blue-400', green: 'bg-green-400',
    purple: 'bg-purple-400', amber: 'bg-amber-400', violet: 'bg-violet-400',
    red: 'bg-red-400', cyan: 'bg-cyan-400',
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title flex items-center gap-2">
            <Activity className="w-6 h-6 text-blue-600 dark:text-blue-400" />
            Journal d'activité
          </h1>
          <p className="page-sub">{filtered.length} événement{filtered.length > 1 ? 's' : ''} enregistré{filtered.length > 1 ? 's' : ''}</p>
        </div>
      </div>

      <div className="card-premium p-3">
        <DateRangeFilter value={dateRange} onChange={setDateRange} />
      </div>

      <div className="flex items-center gap-3 flex-wrap">
        <div className="relative flex-1 min-w-52">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input placeholder="Rechercher dans les logs..." value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
        </div>
        <Select value={filterModule} onValueChange={setFilterModule}>
          <SelectTrigger className="w-40">
            <Filter className="w-3.5 h-3.5 mr-1.5 text-muted-foreground" />
            <SelectValue placeholder="Module" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Tous les modules</SelectItem>
            <SelectItem value="facture">Factures</SelectItem>
            <SelectItem value="paiement">Paiements</SelectItem>
            <SelectItem value="devis">Devis</SelectItem>
            <SelectItem value="prospect">Prospects</SelectItem>
            <SelectItem value="client">Clients</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <div className="card-premium p-6">
        <div className="relative">
          <div className="absolute left-3.5 top-0 bottom-0 w-px bg-border" />
          <div className="space-y-6">
            {filtered.map(log => {
              const Icon = ICONS[log.module] || Activity
              const dot  = COLOR_DOT[log.color] ?? 'bg-blue-400'
              return (
                <div key={log.id} className="flex items-start gap-4 relative">
                  <div className={`w-7 h-7 rounded-full ${dot} flex items-center justify-center flex-shrink-0 z-10`}>
                    <Icon className="w-3.5 h-3.5 text-white" />
                  </div>
                  <div className="flex-1 pt-0.5">
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        <p className="text-sm font-medium text-foreground">{log.action}</p>
                        <p className="text-sm text-muted-foreground mt-0.5">{log.detail}</p>
                      </div>
                      <div className="text-right flex-shrink-0">
                        <p className="text-xs text-muted-foreground whitespace-nowrap">{formatTs(log.date)}</p>
                        <Badge variant="secondary" className="text-[10px] mt-1 capitalize">{log.module}</Badge>
                      </div>
                    </div>
                  </div>
                </div>
              )
            })}
            {filtered.length === 0 && (
              <div className="text-center py-12 text-muted-foreground">
                <Activity className="w-12 h-12 mx-auto mb-3 opacity-30" />
                <p>Aucun événement trouvé</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
