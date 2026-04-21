import { useState } from 'react'
import { motion } from 'framer-motion'
import {
  FileDown, FileText, Receipt, DollarSign, Users, UserCheck,
  Download, Table2, Loader2, Calendar,
} from 'lucide-react'
import { useFactures }  from '@/hooks/useFactures'
import { useDepenses }  from '@/hooks/useDepenses'
import { useClients }   from '@/hooks/useClients'
import { useProspects } from '@/hooks/useProspects'
import { Button } from '@/components/ui/button'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { formatCurrency } from '@/lib/utils'
import { toast } from 'sonner'
import {
  exportFacturesPDF,
  exportCaMensuelPDF,
  exportDepensesPDF,
  exportClientsCSV,
  exportProspectsCSV,
  exportFacturesCSV,
} from '@/lib/exportReports'

const CURRENT_YEAR = new Date().getFullYear()
const YEARS = [CURRENT_YEAR, CURRENT_YEAR - 1, CURRENT_YEAR - 2]

const MONTHS = [
  'Janvier','Février','Mars','Avril','Mai','Juin',
  'Juillet','Août','Septembre','Octobre','Novembre','Décembre',
]

interface ReportCard {
  id:       string
  title:    string
  desc:     string
  icon:     React.ElementType
  color:    string
  bg:       string
  formats:  ('PDF' | 'CSV')[]
  filterType?: 'month-year' | 'year'
}

const REPORTS: ReportCard[] = [
  {
    id: 'factures',
    title: 'Rapport Factures',
    desc: 'Toutes les factures avec statuts, montants HT/TTC et balance',
    icon: Receipt,
    color: 'text-amber-600 dark:text-amber-400',
    bg: 'bg-amber-50 dark:bg-amber-900/20',
    formats: ['PDF', 'CSV'],
    filterType: 'month-year',
  },
  {
    id: 'ca-mensuel',
    title: 'CA Mensuel',
    desc: 'Chiffre d\'affaires par mois sur une année complète',
    icon: FileText,
    color: 'text-blue-600 dark:text-blue-400',
    bg: 'bg-blue-50 dark:bg-blue-900/20',
    formats: ['PDF'],
    filterType: 'year',
  },
  {
    id: 'depenses',
    title: 'Rapport Dépenses',
    desc: 'Toutes les dépenses par catégorie et type sur la période',
    icon: DollarSign,
    color: 'text-red-600 dark:text-red-400',
    bg: 'bg-red-50 dark:bg-red-900/20',
    formats: ['PDF'],
    filterType: 'month-year',
  },
  {
    id: 'clients',
    title: 'Export Clients',
    desc: 'Liste complète des clients avec coordonnées',
    icon: Users,
    color: 'text-emerald-600 dark:text-emerald-400',
    bg: 'bg-emerald-50 dark:bg-emerald-900/20',
    formats: ['CSV'],
  },
  {
    id: 'prospects',
    title: 'Export Prospects',
    desc: 'Pipeline CRM complet avec statuts et valeurs estimées',
    icon: UserCheck,
    color: 'text-violet-600 dark:text-violet-400',
    bg: 'bg-violet-50 dark:bg-violet-900/20',
    formats: ['CSV'],
  },
]

export default function Rapports() {
  const { data: factures  = [] } = useFactures()
  const { data: depenses  = [] } = useDepenses()
  const { data: clients   = [] } = useClients()
  const { data: prospects = [] } = useProspects()
  const [loading, setLoading] = useState<string | null>(null)
  const [month,   setMonth]   = useState(String(new Date().getMonth()))
  const [year,    setYear]    = useState(String(CURRENT_YEAR))

  const withLoading = async (id: string, fn: () => void) => {
    setLoading(id)
    await new Promise(r => setTimeout(r, 200))
    try { fn() } catch (e) { toast.error('Erreur lors de la génération') }
    setLoading(null)
  }

  const periodeLabel = `${MONTHS[Number(month)]} ${year}`

  const filterByPeriod = (items: typeof factures) =>
    items.filter(f => {
      const d = new Date(f.date_emission)
      return d.getFullYear() === Number(year) && d.getMonth() === Number(month)
    })

  const filterDepByPeriod = (items: typeof depenses) =>
    items.filter(d => {
      const dt = new Date(d.date_depense)
      return dt.getFullYear() === Number(year) && dt.getMonth() === Number(month)
    })

  const handleExport = async (report: ReportCard, format: 'PDF' | 'CSV') => {
    const id = `${report.id}-${format}`
    await withLoading(id, () => {
      if (report.id === 'factures' && format === 'PDF') {
        exportFacturesPDF(filterByPeriod(factures), periodeLabel)
      } else if (report.id === 'factures' && format === 'CSV') {
        exportFacturesCSV(filterByPeriod(factures))
      } else if (report.id === 'ca-mensuel') {
        exportCaMensuelPDF(factures, Number(year))
      } else if (report.id === 'depenses') {
        exportDepensesPDF(filterDepByPeriod(depenses), periodeLabel)
      } else if (report.id === 'clients') {
        exportClientsCSV(clients)
      } else if (report.id === 'prospects') {
        exportProspectsCSV(prospects)
      }
      toast.success(`${report.title} — ${format} généré`)
    })
  }

  // Summary stats
  const currMonthFact = filterByPeriod(factures)
  const ca  = currMonthFact.filter(f => f.statut === 'payee').reduce((s,f)=>s+f.montant_ttc,0)
  const dep = filterDepByPeriod(depenses).reduce((s,d)=>s+d.montant,0)

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title flex items-center gap-2">
            <FileDown className="w-6 h-6 text-blue-600 dark:text-blue-400" />
            Rapports & Export
          </h1>
          <p className="text-muted-foreground text-sm mt-1">
            Générez vos rapports PDF ou exportez en CSV
          </p>
        </div>
      </div>

      {/* Period selector */}
      <div className="card-premium p-4 flex flex-wrap items-center gap-4">
        <div className="flex items-center gap-2">
          <Calendar className="w-4 h-4 text-muted-foreground" />
          <span className="text-sm font-medium text-foreground">Période :</span>
        </div>
        <Select value={month} onValueChange={setMonth}>
          <SelectTrigger className="w-36 h-8 text-sm">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            {MONTHS.map((m, i) => <SelectItem key={i} value={String(i)}>{m}</SelectItem>)}
          </SelectContent>
        </Select>
        <Select value={year} onValueChange={setYear}>
          <SelectTrigger className="w-24 h-8 text-sm">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            {YEARS.map(y => <SelectItem key={y} value={String(y)}>{y}</SelectItem>)}
          </SelectContent>
        </Select>

        {/* Quick stats for period */}
        <div className="ml-auto flex items-center gap-6 text-sm">
          <div>
            <span className="text-muted-foreground">CA encaissé : </span>
            <span className="font-semibold text-emerald-600 dark:text-emerald-400">{formatCurrency(ca)}</span>
          </div>
          <div>
            <span className="text-muted-foreground">Dépenses : </span>
            <span className="font-semibold text-red-500">{formatCurrency(dep)}</span>
          </div>
          <div>
            <span className="text-muted-foreground">Net : </span>
            <span className={`font-semibold ${ca - dep >= 0 ? 'text-emerald-600 dark:text-emerald-400' : 'text-red-500'}`}>{formatCurrency(ca - dep)}</span>
          </div>
        </div>
      </div>

      {/* Report cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
        {REPORTS.map((report, i) => (
          <motion.div
            key={report.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.07 }}
            className="card-premium p-5 flex flex-col gap-4"
          >
            <div className="flex items-start gap-3">
              <div className={`w-11 h-11 rounded-xl ${report.bg} flex items-center justify-center flex-shrink-0`}>
                <report.icon className={`w-5 h-5 ${report.color}`} />
              </div>
              <div className="flex-1 min-w-0">
                <h3 className="font-semibold text-foreground text-sm">{report.title}</h3>
                <p className="text-xs text-muted-foreground mt-0.5 leading-relaxed">{report.desc}</p>
              </div>
            </div>

            {/* Info line */}
            {report.filterType === 'month-year' && (
              <p className="text-xs text-muted-foreground bg-muted/40 rounded-lg px-3 py-1.5">
                Période sélectionnée : <span className="font-medium text-foreground">{periodeLabel}</span>
              </p>
            )}
            {report.filterType === 'year' && (
              <p className="text-xs text-muted-foreground bg-muted/40 rounded-lg px-3 py-1.5">
                Année sélectionnée : <span className="font-medium text-foreground">{year}</span>
              </p>
            )}

            {/* Export buttons */}
            <div className="flex items-center gap-2 mt-auto">
              {report.formats.map(fmt => {
                const id    = `${report.id}-${fmt}`
                const isLoading = loading === id
                const isPDF = fmt === 'PDF'
                return (
                  <Button
                    key={fmt}
                    size="sm"
                    variant={isPDF ? 'default' : 'secondary'}
                    className="flex-1"
                    disabled={!!loading}
                    onClick={() => handleExport(report, fmt)}
                  >
                    {isLoading
                      ? <Loader2 className="w-3.5 h-3.5 animate-spin" />
                      : isPDF
                        ? <Download className="w-3.5 h-3.5" />
                        : <Table2 className="w-3.5 h-3.5" />
                    }
                    {fmt}
                  </Button>
                )
              })}
            </div>
          </motion.div>
        ))}
      </div>
    </div>
  )
}
