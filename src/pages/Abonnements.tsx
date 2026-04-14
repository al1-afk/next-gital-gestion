import { useState } from 'react'
import { Plus, Repeat, Edit2, Trash2, AlertTriangle } from 'lucide-react'
import { motion } from 'framer-motion'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { formatCurrency, formatDate, getDaysUntil } from '@/lib/utils'
import { toast } from 'sonner'

interface Abonnement {
  id: string; nom: string; fournisseur: string; montant: number; cycle: 'mensuel' | 'annuel' | 'trimestriel'
  date_renouvellement: string; statut: 'actif' | 'inactif' | 'annule'; categorie: string
}

const MOCK: Abonnement[] = [
  { id: '1', nom: 'Adobe Creative Cloud', fournisseur: 'Adobe', montant: 650, cycle: 'mensuel', date_renouvellement: '2026-05-01', statut: 'actif', categorie: 'Outils' },
  { id: '2', nom: 'Canva Pro', fournisseur: 'Canva', montant: 130, cycle: 'mensuel', date_renouvellement: '2026-04-25', statut: 'actif', categorie: 'Design' },
  { id: '3', nom: 'GitHub Team', fournisseur: 'GitHub', montant: 240, cycle: 'mensuel', date_renouvellement: '2026-05-10', statut: 'actif', categorie: 'Dev' },
  { id: '4', nom: 'Notion Pro', fournisseur: 'Notion', montant: 160, cycle: 'mensuel', date_renouvellement: '2026-06-01', statut: 'actif', categorie: 'Outils' },
  { id: '5', nom: 'AWS S3 + EC2', fournisseur: 'Amazon', montant: 480, cycle: 'mensuel', date_renouvellement: '2026-05-15', statut: 'actif', categorie: 'Infrastructure' },
  { id: '6', nom: 'SendGrid Email', fournisseur: 'Twilio', montant: 200, cycle: 'mensuel', date_renouvellement: '2026-05-20', statut: 'actif', categorie: 'Email' },
]

export default function Abonnements() {
  const [abonnements, setAbonnements] = useState(MOCK)
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ nom: '', fournisseur: '', montant: 0, cycle: 'mensuel' as Abonnement['cycle'], date_renouvellement: '', statut: 'actif' as Abonnement['statut'], categorie: '' })

  const totalMensuel = abonnements.filter(a => a.statut === 'actif').reduce((s, a) => {
    if (a.cycle === 'mensuel') return s + a.montant
    if (a.cycle === 'annuel') return s + a.montant / 12
    if (a.cycle === 'trimestriel') return s + a.montant / 3
    return s
  }, 0)

  const save = () => {
    if (!form.nom) return
    setAbonnements(prev => [{ ...form, id: Date.now().toString() }, ...prev])
    setShowForm(false)
    toast.success('Abonnement ajouté')
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Abonnements</h1>
          <p className="text-muted-foreground text-sm mt-1">{abonnements.filter(a => a.statut === 'actif').length} actifs · {formatCurrency(totalMensuel)}/mois</p>
        </div>
        <Button size="sm" onClick={() => setShowForm(true)}><Plus className="w-4 h-4" /> Ajouter</Button>
      </div>

      <div className="grid grid-cols-3 gap-4">
        <div className="card p-4"><p className="text-xs text-muted-foreground mb-1">Coût mensuel</p><p className="text-xl font-bold text-foreground">{formatCurrency(totalMensuel)}</p></div>
        <div className="card p-4"><p className="text-xs text-muted-foreground mb-1">Coût annuel</p><p className="text-xl font-bold text-blue-400">{formatCurrency(totalMensuel * 12)}</p></div>
        <div className="card p-4"><p className="text-xs text-muted-foreground mb-1">Renouvellements à venir</p><p className="text-xl font-bold text-yellow-400">{abonnements.filter(a => getDaysUntil(a.date_renouvellement) <= 30 && a.statut === 'actif').length}</p></div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
        {abonnements.map((a, i) => {
          const days = getDaysUntil(a.date_renouvellement)
          return (
            <motion.div key={a.id} initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.04 }}
              className={`card p-4 hover:border-blue-500/30 transition-all group ${days <= 15 ? 'border-yellow-500/20' : ''}`}>
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center gap-2">
                  <div className="w-9 h-9 rounded-lg bg-blue-500/20 flex items-center justify-center flex-shrink-0">
                    <Repeat className="w-4 h-4 text-blue-400" />
                  </div>
                  <div>
                    <p className="font-medium text-foreground text-sm">{a.nom}</p>
                    <p className="text-xs text-muted-foreground">{a.fournisseur}</p>
                  </div>
                </div>
                {days <= 15 && <AlertTriangle className="w-4 h-4 text-yellow-400 flex-shrink-0" />}
              </div>
              <div className="flex items-center justify-between text-sm">
                <div>
                  <p className="text-lg font-bold text-foreground">{formatCurrency(a.montant)}</p>
                  <p className="text-xs text-muted-foreground capitalize">/ {a.cycle}</p>
                </div>
                <div className="text-right">
                  <p className="text-xs text-muted-foreground">Renouvellement</p>
                  <p className="text-xs font-medium text-foreground">{formatDate(a.date_renouvellement)}</p>
                  <Badge variant={days <= 15 ? 'warning' : 'secondary'} className="text-[10px] mt-0.5">{days}j</Badge>
                </div>
              </div>
              <div className="mt-3 pt-2 border-t border-border flex items-center justify-between">
                <span className="text-xs text-muted-foreground00 capitalize">{a.categorie}</span>
                <Button variant="ghost" size="icon" className="w-7 h-7 text-red-400 opacity-0 group-hover:opacity-100"
                  onClick={() => { setAbonnements(prev => prev.filter(x => x.id !== a.id)); toast.success('Supprimé') }}>
                  <Trash2 className="w-3.5 h-3.5" />
                </Button>
              </div>
            </motion.div>
          )
        })}
      </div>

      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent>
          <DialogHeader><DialogTitle>Nouvel abonnement</DialogTitle></DialogHeader>
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5 col-span-2"><label className="form-label">Nom *</label><Input value={form.nom} onChange={e => setForm(p => ({ ...p, nom: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Fournisseur</label><Input value={form.fournisseur} onChange={e => setForm(p => ({ ...p, fournisseur: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Catégorie</label><Input value={form.categorie} onChange={e => setForm(p => ({ ...p, categorie: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Montant (MAD)</label><Input type="number" value={form.montant} onChange={e => setForm(p => ({ ...p, montant: +e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Cycle</label>
                <Select value={form.cycle} onValueChange={v => setForm(p => ({ ...p, cycle: v as Abonnement['cycle'] }))}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="mensuel">Mensuel</SelectItem>
                    <SelectItem value="trimestriel">Trimestriel</SelectItem>
                    <SelectItem value="annuel">Annuel</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-1.5 col-span-2"><label className="form-label">Prochain renouvellement</label><Input type="date" value={form.date_renouvellement} onChange={e => setForm(p => ({ ...p, date_renouvellement: e.target.value }))} /></div>
            </div>
            <div className="flex justify-end gap-3">
              <Button variant="secondary" onClick={() => setShowForm(false)}>Annuler</Button>
              <Button onClick={save}>Ajouter</Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
