import { useState } from 'react'
import { Plus, ShoppingCart, Loader2, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { formatCurrency, formatDate } from '@/lib/utils'
import { toast } from 'sonner'

interface BonCommande { id: string; numero: string; fournisseur: string; objet: string; montant: number; date: string; statut: 'envoye' | 'recu' | 'partiel' | 'annule' }

const MOCK: BonCommande[] = [
  { id: '1', numero: 'BC-2026-001', fournisseur: 'Adobe Inc.', objet: 'Licences Creative Cloud x5', montant: 3250, date: '2026-04-01', statut: 'recu' },
  { id: '2', numero: 'BC-2026-002', fournisseur: 'Bureau Office MA', objet: 'Fournitures bureau Q2', montant: 850, date: '2026-04-05', statut: 'envoye' },
  { id: '3', numero: 'BC-2026-003', fournisseur: 'Contabo GmbH', objet: 'Renouvellement VPS 12 mois', montant: 4200, date: '2026-04-08', statut: 'recu' },
]

const STATUT_CONFIG = {
  envoye:  { label: 'Envoyé',    variant: 'default' as const },
  recu:    { label: 'Reçu',      variant: 'success' as const },
  partiel: { label: 'Partiel',   variant: 'warning' as const },
  annule:  { label: 'Annulé',    variant: 'destructive' as const },
}

export default function BonsCommande() {
  const [bons, setBons] = useState(MOCK)
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ numero: '', fournisseur: '', objet: '', montant: 0, date: new Date().toISOString().slice(0, 10), statut: 'envoye' as BonCommande['statut'] })

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Bons de commande</h1>
          <p className="text-muted-foreground text-sm mt-1">{bons.length} bons · {formatCurrency(bons.reduce((s, b) => s + b.montant, 0))} total</p>
        </div>
        <Button size="sm" onClick={() => setShowForm(true)}><Plus className="w-4 h-4" /> Nouveau</Button>
      </div>

      <div className="card overflow-hidden">
        <table className="w-full">
          <thead><tr className="table-header"><th>N° BC</th><th>Fournisseur</th><th>Objet</th><th>Date</th><th>Montant</th><th>Statut</th><th></th></tr></thead>
          <tbody>
            {bons.map(b => (
              <tr key={b.id} className="table-row group">
                <td className="font-mono font-medium text-foreground">{b.numero}</td>
                <td className="text-muted-foreground">{b.fournisseur}</td>
                <td className="text-muted-foreground text-sm">{b.objet}</td>
                <td className="text-muted-foreground">{formatDate(b.date)}</td>
                <td className="font-semibold text-foreground">{formatCurrency(b.montant)}</td>
                <td><Badge variant={STATUT_CONFIG[b.statut].variant}>{STATUT_CONFIG[b.statut].label}</Badge></td>
                <td>
                  <Button variant="ghost" size="icon" className="w-7 h-7 text-red-400 opacity-0 group-hover:opacity-100" onClick={() => { setBons(prev => prev.filter(x => x.id !== b.id)); toast.success('Supprimé') }}>
                    <Trash2 className="w-3.5 h-3.5" />
                  </Button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {bons.length === 0 && <div className="empty-state"><ShoppingCart className="empty-state-icon" /><p className="empty-state-title">Aucun bon de commande</p></div>}
      </div>

      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent>
          <DialogHeader><DialogTitle>Nouveau bon de commande</DialogTitle></DialogHeader>
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5"><label className="form-label">N° BC</label><Input value={form.numero} onChange={e => setForm(p => ({ ...p, numero: e.target.value }))} placeholder={`BC-${new Date().getFullYear()}-00X`} /></div>
              <div className="space-y-1.5"><label className="form-label">Fournisseur</label><Input value={form.fournisseur} onChange={e => setForm(p => ({ ...p, fournisseur: e.target.value }))} /></div>
              <div className="space-y-1.5 col-span-2"><label className="form-label">Objet</label><Input value={form.objet} onChange={e => setForm(p => ({ ...p, objet: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Montant (MAD)</label><Input type="number" value={form.montant} onChange={e => setForm(p => ({ ...p, montant: +e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Date</label><Input type="date" value={form.date} onChange={e => setForm(p => ({ ...p, date: e.target.value }))} /></div>
              <div className="space-y-1.5 col-span-2"><label className="form-label">Statut</label>
                <Select value={form.statut} onValueChange={v => setForm(p => ({ ...p, statut: v as BonCommande['statut'] }))}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>{Object.entries(STATUT_CONFIG).map(([k, v]) => <SelectItem key={k} value={k}>{v.label}</SelectItem>)}</SelectContent>
                </Select>
              </div>
            </div>
            <div className="flex justify-end gap-3">
              <Button variant="secondary" onClick={() => setShowForm(false)}>Annuler</Button>
              <Button onClick={() => { if (!form.fournisseur) return; setBons(prev => [{ ...form, id: Date.now().toString() }, ...prev]); setShowForm(false); toast.success('Bon de commande créé') }}>Créer</Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
