import { useState, useMemo } from 'react'
import { Plus, Search, CreditCard, Loader2, Trash2, Edit2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { formatCurrency, formatDate, PAYMENT_METHODS } from '@/lib/utils'
import { toast } from 'sonner'

interface Paiement {
  id: string; reference: string; montant: number; mode: string; date: string; client: string; facture: string; statut: string
}

const MOCK: Paiement[] = [
  { id: '1', reference: 'VIR-001', montant: 32542.37, mode: 'virement', date: '2026-04-05', client: 'Hôtel Atlas', facture: 'FAC-2026-001', statut: 'encaisse' },
  { id: '2', reference: 'ESP-001', montant: 6000, mode: 'especes', date: '2026-04-08', client: 'Immobilier Premium', facture: 'FAC-2026-003', statut: 'encaisse' },
  { id: '3', reference: 'CHQ-001', montant: 5000, mode: 'cheque', date: '2026-03-28', client: 'Mode & Co', facture: 'FAC-2026-005', statut: 'encaisse' },
  { id: '4', reference: 'VIR-002', montant: 8500, mode: 'virement', date: '2026-04-10', client: 'PharmaTech', facture: 'FAC-2026-002', statut: 'en_attente' },
]

const MODE_ICONS: Record<string, string> = { virement: '🏦', especes: '💵', cheque: '📝', carte: '💳', autre: '📦' }

export default function Paiements() {
  const [paiements] = useState(MOCK)
  const [search, setSearch] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ montant: 0, mode: 'virement', date: new Date().toISOString().slice(0, 10), reference: '', notes: '' })

  const filtered = useMemo(() => paiements.filter(p => !search || [p.reference, p.client, p.facture].some(x => x.toLowerCase().includes(search.toLowerCase()))), [paiements, search])
  const total = useMemo(() => filtered.reduce((s, p) => s + p.montant, 0), [filtered])

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Paiements</h1>
          <p className="text-muted-foreground text-sm mt-1">{paiements.length} paiements · {formatCurrency(total)} encaissé</p>
        </div>
        <Button size="sm" onClick={() => setShowForm(true)}><Plus className="w-4 h-4" /> Enregistrer</Button>
      </div>

      <div className="grid grid-cols-3 gap-4">
        <div className="card p-4">
          <p className="text-xs text-muted-foreground uppercase tracking-wider mb-1">Total encaissé</p>
          <p className="text-xl font-bold text-emerald-400">{formatCurrency(total)}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-muted-foreground uppercase tracking-wider mb-1">Ce mois</p>
          <p className="text-xl font-bold text-foreground">{paiements.length} paiements</p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-muted-foreground uppercase tracking-wider mb-1">En attente</p>
          <p className="text-xl font-bold text-yellow-400">{paiements.filter(p => p.statut === 'en_attente').length}</p>
        </div>
      </div>

      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
        <Input placeholder="Rechercher..." value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
      </div>

      <div className="card overflow-hidden">
        <table className="w-full">
          <thead><tr className="table-header"><th>Référence</th><th>Client</th><th>Facture</th><th>Mode</th><th>Date</th><th>Montant</th><th>Statut</th></tr></thead>
          <tbody>
            {filtered.map(p => (
              <tr key={p.id} className="table-row">
                <td className="font-mono text-foreground">{p.reference}</td>
                <td className="text-muted-foreground">{p.client}</td>
                <td className="text-muted-foreground text-sm">{p.facture}</td>
                <td><span className="text-sm">{MODE_ICONS[p.mode]} {p.mode}</span></td>
                <td className="text-muted-foreground">{formatDate(p.date)}</td>
                <td className="font-semibold text-emerald-400">{formatCurrency(p.montant)}</td>
                <td><Badge variant={p.statut === 'encaisse' ? 'success' : 'warning'}>{p.statut === 'encaisse' ? 'Encaissé' : 'En attente'}</Badge></td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 && <div className="empty-state"><CreditCard className="empty-state-icon" /><p className="empty-state-title">Aucun paiement</p></div>}
      </div>

      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent>
          <DialogHeader><DialogTitle>Enregistrer un paiement</DialogTitle></DialogHeader>
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5"><label className="form-label">Montant (MAD)</label><Input type="number" value={form.montant} onChange={e => setForm(p => ({ ...p, montant: +e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Mode</label>
                <Select value={form.mode} onValueChange={v => setForm(p => ({ ...p, mode: v }))}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>{PAYMENT_METHODS.map(m => <SelectItem key={m.value} value={m.value}>{m.label}</SelectItem>)}</SelectContent>
                </Select>
              </div>
              <div className="space-y-1.5"><label className="form-label">Date</label><Input type="date" value={form.date} onChange={e => setForm(p => ({ ...p, date: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Référence</label><Input value={form.reference} onChange={e => setForm(p => ({ ...p, reference: e.target.value }))} /></div>
            </div>
            <div className="flex justify-end gap-3">
              <Button variant="secondary" onClick={() => setShowForm(false)}>Annuler</Button>
              <Button onClick={() => { toast.success('Paiement enregistré'); setShowForm(false) }}>Enregistrer</Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
