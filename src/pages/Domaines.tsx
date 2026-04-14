import { useState } from 'react'
import { motion } from 'framer-motion'
import { Plus, Globe, AlertTriangle, CheckCircle2, Clock, Edit2, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { formatCurrency, formatDate, getDaysUntil } from '@/lib/utils'
import { toast } from 'sonner'

interface Domaine {
  id: string; nom: string; registrar: string; date_expiration: string
  prix_renouvellement: number; client?: string; notes?: string
}

const MOCK: Domaine[] = [
  { id: '1', nom: 'nextgital.ma', registrar: 'MarkDomain', date_expiration: '2026-05-15', prix_renouvellement: 120, client: 'NextGital' },
  { id: '2', nom: 'nextgital.com', registrar: 'GoDaddy', date_expiration: '2026-06-01', prix_renouvellement: 150, client: 'NextGital' },
  { id: '3', nom: 'hotelAtlas.ma', registrar: 'MarkDomain', date_expiration: '2026-07-20', prix_renouvellement: 120, client: 'Hôtel Atlas' },
  { id: '4', nom: 'pharmaTech.ma', registrar: 'Gandi', date_expiration: '2026-08-10', prix_renouvellement: 130, client: 'PharmaTech' },
  { id: '5', nom: 'immo-premium.ma', registrar: 'MarkDomain', date_expiration: '2026-09-15', prix_renouvellement: 120, client: 'Immobilier Premium' },
]

function getUrgencyBadge(days: number) {
  if (days <= 0) return <Badge variant="destructive">Expiré</Badge>
  if (days <= 15) return <Badge variant="destructive">{days}j restants</Badge>
  if (days <= 30) return <Badge variant="warning">{days}j restants</Badge>
  if (days <= 60) return <Badge variant="default">{days}j restants</Badge>
  return <Badge variant="success">{days}j restants</Badge>
}

export default function Domaines() {
  const [domaines, setDomaines] = useState(MOCK)
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ nom: '', registrar: '', date_expiration: '', prix_renouvellement: 120, client: '', notes: '' })

  const sorted = [...domaines].sort((a, b) => getDaysUntil(a.date_expiration) - getDaysUntil(b.date_expiration))

  const add = () => {
    if (!form.nom) return
    setDomaines(prev => [{ ...form, id: Date.now().toString() }, ...prev])
    setShowForm(false)
    toast.success('Domaine ajouté')
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Domaines</h1>
          <p className="text-muted-foreground text-sm mt-1">{domaines.length} domaines gérés</p>
        </div>
        <Button size="sm" onClick={() => setShowForm(true)}><Plus className="w-4 h-4" /> Ajouter</Button>
      </div>

      <div className="grid grid-cols-3 gap-4">
        <div className="card p-4">
          <p className="text-xs text-muted-foreground mb-1 uppercase tracking-wider">Total domaines</p>
          <p className="text-xl font-bold text-foreground">{domaines.length}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-muted-foreground mb-1 uppercase tracking-wider">Expirent dans 30j</p>
          <p className="text-xl font-bold text-yellow-400">{domaines.filter(d => getDaysUntil(d.date_expiration) <= 30).length}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-muted-foreground mb-1 uppercase tracking-wider">Budget renouvellements</p>
          <p className="text-xl font-bold text-blue-400">{formatCurrency(domaines.reduce((s, d) => s + d.prix_renouvellement, 0))}</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
        {sorted.map((d, i) => {
          const days = getDaysUntil(d.date_expiration)
          return (
            <motion.div
              key={d.id}
              initial={{ opacity: 0, y: 12 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.04 }}
              className={`card p-4 hover:border-blue-500/30 transition-all group ${days <= 30 ? 'border-yellow-500/30' : days <= 15 ? 'border-red-500/30' : ''}`}
            >
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-2">
                  <div className="w-9 h-9 rounded-lg bg-blue-500/20 flex items-center justify-center">
                    <Globe className="w-4 h-4 text-blue-400" />
                  </div>
                  <div>
                    <p className="font-semibold text-foreground text-sm">{d.nom}</p>
                    <p className="text-xs text-muted-foreground">{d.registrar}</p>
                  </div>
                </div>
                {getUrgencyBadge(days)}
              </div>
              <div className="mt-3 space-y-1.5 text-xs text-muted-foreground">
                <div className="flex justify-between"><span>Expiration</span><span className="text-foreground">{formatDate(d.date_expiration)}</span></div>
                <div className="flex justify-between"><span>Renouvellement</span><span className="text-blue-400 font-medium">{formatCurrency(d.prix_renouvellement)}</span></div>
                {d.client && <div className="flex justify-between"><span>Client</span><span className="text-muted-foreground">{d.client}</span></div>}
              </div>
              <div className="mt-3 pt-2 border-t border-border flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                <Button variant="ghost" size="icon" className="w-7 h-7 text-red-400"
                  onClick={() => { setDomaines(prev => prev.filter(x => x.id !== d.id)); toast.success('Domaine supprimé') }}>
                  <Trash2 className="w-3.5 h-3.5" />
                </Button>
              </div>
            </motion.div>
          )
        })}
      </div>

      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent>
          <DialogHeader><DialogTitle>Ajouter un domaine</DialogTitle></DialogHeader>
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5 col-span-2"><label className="form-label">Nom de domaine *</label>
                <Input value={form.nom} onChange={e => setForm(p => ({ ...p, nom: e.target.value }))} placeholder="exemple.ma" /></div>
              <div className="space-y-1.5"><label className="form-label">Registrar</label>
                <Input value={form.registrar} onChange={e => setForm(p => ({ ...p, registrar: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Date expiration</label>
                <Input type="date" value={form.date_expiration} onChange={e => setForm(p => ({ ...p, date_expiration: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Prix renouvellement (MAD)</label>
                <Input type="number" value={form.prix_renouvellement} onChange={e => setForm(p => ({ ...p, prix_renouvellement: +e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Client associé</label>
                <Input value={form.client} onChange={e => setForm(p => ({ ...p, client: e.target.value }))} /></div>
            </div>
            <div className="flex justify-end gap-3">
              <Button variant="secondary" onClick={() => setShowForm(false)}>Annuler</Button>
              <Button onClick={add}>Ajouter</Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
