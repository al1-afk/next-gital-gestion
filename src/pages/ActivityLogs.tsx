import { useState } from 'react'
import { Search, Activity, User, FileText, Receipt, UserCheck, DollarSign, Trash2 } from 'lucide-react'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { formatDate } from '@/lib/utils'

const ICONS: Record<string, React.ElementType> = {
  prospect: UserCheck,
  client: User,
  devis: FileText,
  facture: Receipt,
  paiement: DollarSign,
  contrat: FileText,
}

const ACTIONS = [
  { id: '1', module: 'facture', action: 'Paiement reçu', detail: 'FAC-2026-001 payée — 32 542 MAD', user: 'Said', date: '2026-04-12 10:23', color: 'emerald' },
  { id: '2', module: 'prospect', action: 'Prospect ajouté', detail: 'Karim Alaoui — Corp Solutions', user: 'Said', date: '2026-04-12 09:45', color: 'blue' },
  { id: '3', module: 'devis', action: 'Devis accepté', detail: 'DEV-2026-001 — Hôtel Atlas', user: 'Said', date: '2026-04-11 16:30', color: 'green' },
  { id: '4', module: 'client', action: 'Client créé', detail: 'Mehdi Berrada — FoodTech MA', user: 'Said', date: '2026-04-11 14:15', color: 'purple' },
  { id: '5', module: 'contrat', action: 'Contrat signé', detail: 'CTR-2026-001 — Hôtel Atlas · 32 000 MAD', user: 'Said', date: '2026-04-10 11:00', color: 'blue' },
  { id: '6', module: 'facture', action: 'Facture créée', detail: 'FAC-2026-004 — FoodTech MA · 20 000 MAD', user: 'Said', date: '2026-04-08 09:30', color: 'yellow' },
  { id: '7', module: 'prospect', action: 'Statut modifié', detail: 'Fatima Zahra → Proposition envoyée', user: 'Said', date: '2026-04-07 15:45', color: 'cyan' },
  { id: '8', module: 'devis', action: 'Devis refusé', detail: 'DEV-2026-004 — Mode & Co', user: 'Said', date: '2026-04-06 13:20', color: 'red' },
]

const COLOR_DOT: Record<string, string> = {
  emerald: 'bg-emerald-400', blue: 'bg-blue-400', green: 'bg-green-400',
  purple: 'bg-purple-400', yellow: 'bg-yellow-400', cyan: 'bg-cyan-400', red: 'bg-red-400',
}

export default function ActivityLogs() {
  const [search, setSearch] = useState('')
  const filtered = ACTIONS.filter(a => !search || [a.action, a.detail, a.module].some(x => x.toLowerCase().includes(search.toLowerCase())))

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title flex items-center gap-2">
            <Activity className="w-6 h-6 text-blue-400" />
            Journal d'activité
          </h1>
          <p className="text-slate-500 text-sm mt-1">{ACTIONS.length} événements enregistrés</p>
        </div>
      </div>

      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
        <Input placeholder="Rechercher dans les logs..." value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
      </div>

      <div className="card p-6">
        <div className="relative">
          {/* Timeline line */}
          <div className="absolute left-3.5 top-0 bottom-0 w-px bg-border" />
          <div className="space-y-6">
            {filtered.map((log, i) => {
              const Icon = ICONS[log.module] || Activity
              return (
                <div key={log.id} className="flex items-start gap-4 relative">
                  <div className={`w-7 h-7 rounded-full ${COLOR_DOT[log.color] || 'bg-blue-400'} flex items-center justify-center flex-shrink-0 z-10`}>
                    <Icon className="w-3.5 h-3.5 text-white" />
                  </div>
                  <div className="flex-1 pt-0.5">
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        <p className="text-sm font-medium text-foreground">{log.action}</p>
                        <p className="text-sm text-muted-foreground mt-0.5">{log.detail}</p>
                      </div>
                      <div className="text-right flex-shrink-0">
                        <p className="text-xs text-muted-foreground whitespace-nowrap">{log.date}</p>
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
