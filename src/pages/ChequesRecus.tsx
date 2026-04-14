import { useState } from 'react'
import { Plus, Banknote, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { formatCurrency, formatDate } from '@/lib/utils'
import { toast } from 'sonner'

interface Cheque { id: string; reference: string; montant: number; emetteur: string; banque: string; date_reception: string; date_depot?: string; statut: 'recu' | 'depose' | 'encaisse' | 'refuse' | 'annule' }

const MOCK: Cheque[] = [
  { id: '1', reference: 'CHQ-2026-001', montant: 6000, emetteur: 'Immobilier Premium', banque: 'CIH Bank', date_reception: '2026-04-05', date_depot: '2026-04-06', statut: 'encaisse' },
  { id: '2', reference: 'CHQ-2026-002', montant: 5000, emetteur: 'Mode & Co', banque: 'BMCE', date_reception: '2026-04-08', statut: 'depose' },
  { id: '3', reference: 'CHQ-2026-003', montant: 12000, emetteur: 'FoodTech MA', banque: 'Attijariwafa', date_reception: '2026-04-10', statut: 'recu' },
]

const STATUT = {
  recu:     { label: 'Reçu',     variant: 'default' as const },
  depose:   { label: 'Déposé',   variant: 'default' as const },
  encaisse: { label: 'Encaissé', variant: 'success' as const },
  refuse:   { label: 'Refusé',   variant: 'destructive' as const },
  annule:   { label: 'Annulé',   variant: 'secondary' as const },
}

export default function ChequesRecus() {
  const [cheques, setCheques] = useState(MOCK)
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ reference: '', montant: 0, emetteur: '', banque: '', date_reception: new Date().toISOString().slice(0, 10), statut: 'recu' as Cheque['statut'] })

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Chèques reçus</h1>
          <p className="text-muted-foreground text-sm mt-1">{cheques.length} chèques · {formatCurrency(cheques.reduce((s, c) => s + c.montant, 0))}</p>
        </div>
        <Button size="sm" onClick={() => setShowForm(true)}><Plus className="w-4 h-4" /> Enregistrer</Button>
      </div>

      <div className="card overflow-hidden">
        <table className="w-full">
          <thead><tr className="table-header"><th>Référence</th><th>Émetteur</th><th>Banque</th><th>Réception</th><th>Dépôt</th><th>Montant</th><th>Statut</th><th></th></tr></thead>
          <tbody>
            {cheques.map(c => (
              <tr key={c.id} className="table-row group">
                <td className="font-mono text-foreground">{c.reference}</td>
                <td className="text-muted-foreground">{c.emetteur}</td>
                <td className="text-muted-foreground">{c.banque}</td>
                <td className="text-muted-foreground">{formatDate(c.date_reception)}</td>
                <td className="text-muted-foreground">{c.date_depot ? formatDate(c.date_depot) : '—'}</td>
                <td className="font-semibold text-emerald-400">{formatCurrency(c.montant)}</td>
                <td><Badge variant={STATUT[c.statut].variant}>{STATUT[c.statut].label}</Badge></td>
                <td><Button variant="ghost" size="icon" className="w-7 h-7 text-red-400 opacity-0 group-hover:opacity-100" onClick={() => { setCheques(p => p.filter(x => x.id !== c.id)); toast.success('Supprimé') }}><Trash2 className="w-3.5 h-3.5" /></Button></td>
              </tr>
            ))}
          </tbody>
        </table>
        {cheques.length === 0 && <div className="empty-state"><Banknote className="empty-state-icon" /><p className="empty-state-title">Aucun chèque</p></div>}
      </div>

      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent>
          <DialogHeader><DialogTitle>Enregistrer un chèque reçu</DialogTitle></DialogHeader>
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5"><label className="form-label">Référence</label><Input value={form.reference} onChange={e => setForm(p => ({ ...p, reference: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Montant (MAD)</label><Input type="number" value={form.montant} onChange={e => setForm(p => ({ ...p, montant: +e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Émetteur</label><Input value={form.emetteur} onChange={e => setForm(p => ({ ...p, emetteur: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Banque</label><Input value={form.banque} onChange={e => setForm(p => ({ ...p, banque: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Date réception</label><Input type="date" value={form.date_reception} onChange={e => setForm(p => ({ ...p, date_reception: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Statut</label>
                <Select value={form.statut} onValueChange={v => setForm(p => ({ ...p, statut: v as Cheque['statut'] }))}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>{Object.entries(STATUT).map(([k, v]) => <SelectItem key={k} value={k}>{v.label}</SelectItem>)}</SelectContent>
                </Select>
              </div>
            </div>
            <div className="flex justify-end gap-3">
              <Button variant="secondary" onClick={() => setShowForm(false)}>Annuler</Button>
              <Button onClick={() => { if (!form.emetteur) return; setCheques(p => [{ ...form, id: Date.now().toString() }, ...p]); setShowForm(false); toast.success('Enregistré') }}>Enregistrer</Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
