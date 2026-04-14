import { useState } from 'react'
import { motion } from 'framer-motion'
import { Plus, Server, AlertTriangle, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { formatCurrency, formatDate, getDaysUntil } from '@/lib/utils'
import { toast } from 'sonner'

interface Hebergement {
  id: string; nom: string; fournisseur: string; date_expiration: string
  prix_mensuel: number; client?: string; type: string; notes?: string
}

const MOCK: Hebergement[] = [
  { id: '1', nom: 'VPS Contabo Principal', fournisseur: 'Contabo', date_expiration: '2026-04-30', prix_mensuel: 350, client: 'NextGital', type: 'VPS' },
  { id: '2', nom: 'cPanel Hébergement Mutualisé', fournisseur: 'OVH', date_expiration: '2026-06-15', prix_mensuel: 120, client: 'PharmaTech', type: 'Shared' },
  { id: '3', nom: 'Serveur Dédié', fournisseur: 'Hetzner', date_expiration: '2026-08-01', prix_mensuel: 850, client: 'Hôtel Atlas', type: 'Dédié' },
  { id: '4', nom: 'CDN Cloudflare Pro', fournisseur: 'Cloudflare', date_expiration: '2026-09-20', prix_mensuel: 200, type: 'CDN' },
]

export default function Hebergements() {
  const [hebergements, setHebergements] = useState(MOCK)
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ nom: '', fournisseur: '', date_expiration: '', prix_mensuel: 0, client: '', type: 'VPS', notes: '' })

  const sorted = [...hebergements].sort((a, b) => getDaysUntil(a.date_expiration) - getDaysUntil(b.date_expiration))

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Hébergements</h1>
          <p className="text-muted-foreground text-sm mt-1">{hebergements.length} hébergements · {formatCurrency(hebergements.reduce((s, h) => s + h.prix_mensuel, 0))}/mois</p>
        </div>
        <Button size="sm" onClick={() => setShowForm(true)}><Plus className="w-4 h-4" /> Ajouter</Button>
      </div>

      <div className="grid grid-cols-3 gap-4">
        <div className="card p-4"><p className="text-xs text-muted-foreground mb-1">Total hébergements</p><p className="text-xl font-bold text-foreground">{hebergements.length}</p></div>
        <div className="card p-4"><p className="text-xs text-muted-foreground mb-1">Coût mensuel</p><p className="text-xl font-bold text-blue-400">{formatCurrency(hebergements.reduce((s, h) => s + h.prix_mensuel, 0))}</p></div>
        <div className="card p-4"><p className="text-xs text-muted-foreground mb-1">Expirent dans 30j</p><p className="text-xl font-bold text-yellow-400">{hebergements.filter(h => getDaysUntil(h.date_expiration) <= 30).length}</p></div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
        {sorted.map((h, i) => {
          const days = getDaysUntil(h.date_expiration)
          return (
            <motion.div key={h.id} initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.04 }}
              className={`card p-4 group hover:border-blue-500/30 transition-all ${days <= 15 ? 'border-red-500/20' : days <= 30 ? 'border-yellow-500/20' : ''}`}>
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-2">
                  <div className="w-9 h-9 rounded-lg bg-purple-500/20 flex items-center justify-center">
                    <Server className="w-4 h-4 text-purple-400" />
                  </div>
                  <div>
                    <p className="font-medium text-foreground text-sm">{h.nom}</p>
                    <p className="text-xs text-muted-foreground">{h.fournisseur} · {h.type}</p>
                  </div>
                </div>
                <Badge variant={days <= 15 ? 'destructive' : days <= 30 ? 'warning' : 'success'}>{days}j</Badge>
              </div>
              <div className="mt-3 space-y-1.5 text-xs text-muted-foreground">
                <div className="flex justify-between"><span>Expiration</span><span className="text-foreground">{formatDate(h.date_expiration)}</span></div>
                <div className="flex justify-between"><span>Prix mensuel</span><span className="text-blue-400 font-medium">{formatCurrency(h.prix_mensuel)}</span></div>
                {h.client && <div className="flex justify-between"><span>Client</span><span className="text-muted-foreground">{h.client}</span></div>}
              </div>
              <div className="mt-3 pt-2 border-t border-border flex justify-end opacity-0 group-hover:opacity-100 transition-opacity">
                <Button variant="ghost" size="icon" className="w-7 h-7 text-red-400" onClick={() => { setHebergements(prev => prev.filter(x => x.id !== h.id)); toast.success('Supprimé') }}>
                  <Trash2 className="w-3.5 h-3.5" />
                </Button>
              </div>
            </motion.div>
          )
        })}
      </div>

      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent>
          <DialogHeader><DialogTitle>Ajouter un hébergement</DialogTitle></DialogHeader>
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5 col-span-2"><label className="form-label">Nom *</label><Input value={form.nom} onChange={e => setForm(p => ({ ...p, nom: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Fournisseur</label><Input value={form.fournisseur} onChange={e => setForm(p => ({ ...p, fournisseur: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Type</label><Input value={form.type} onChange={e => setForm(p => ({ ...p, type: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Date expiration</label><Input type="date" value={form.date_expiration} onChange={e => setForm(p => ({ ...p, date_expiration: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Prix mensuel (MAD)</label><Input type="number" value={form.prix_mensuel} onChange={e => setForm(p => ({ ...p, prix_mensuel: +e.target.value }))} /></div>
              <div className="space-y-1.5 col-span-2"><label className="form-label">Client</label><Input value={form.client} onChange={e => setForm(p => ({ ...p, client: e.target.value }))} /></div>
            </div>
            <div className="flex justify-end gap-3">
              <Button variant="secondary" onClick={() => setShowForm(false)}>Annuler</Button>
              <Button onClick={() => { if (!form.nom) return; setHebergements(prev => [{ ...form, id: Date.now().toString() }, ...prev]); setShowForm(false); toast.success('Ajouté') }}>Ajouter</Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
