import { useState } from 'react'
import { Plus, Wallet, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { formatCurrency, formatDate } from '@/lib/utils'
import { toast } from 'sonner'

interface ChequeEmis { id: string; reference: string; montant: number; beneficiaire: string; banque: string; date_emission: string; statut: 'emis' | 'encaisse' | 'refuse' | 'annule' }

const MOCK: ChequeEmis[] = [
  { id: '1', reference: 'CE-2026-001', montant: 3250, beneficiaire: 'Adobe Inc.', banque: 'CIH Bank', date_emission: '2026-04-01', statut: 'encaisse' },
  { id: '2', reference: 'CE-2026-002', montant: 850, beneficiaire: 'Bureau Office MA', banque: 'CIH Bank', date_emission: '2026-04-05', statut: 'emis' },
]

const STATUT = {
  emis:     { label: 'Émis',     variant: 'default' as const },
  encaisse: { label: 'Encaissé', variant: 'success' as const },
  refuse:   { label: 'Refusé',   variant: 'destructive' as const },
  annule:   { label: 'Annulé',   variant: 'secondary' as const },
}

export default function ChequesEmis() {
  const [cheques, setCheques] = useState(MOCK)
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ reference: '', montant: 0, beneficiaire: '', banque: 'CIH Bank', date_emission: new Date().toISOString().slice(0, 10), statut: 'emis' as ChequeEmis['statut'] })

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Chèques émis</h1>
          <p className="text-muted-foreground text-sm mt-1">{cheques.length} chèques · {formatCurrency(cheques.reduce((s, c) => s + c.montant, 0))}</p>
        </div>
        <Button size="sm" onClick={() => setShowForm(true)}><Plus className="w-4 h-4" /> Enregistrer</Button>
      </div>
      <div className="card overflow-hidden">
        <table className="w-full">
          <thead><tr className="table-header"><th>Référence</th><th>Bénéficiaire</th><th>Banque</th><th>Date émission</th><th>Montant</th><th>Statut</th><th></th></tr></thead>
          <tbody>
            {cheques.map(c => (
              <tr key={c.id} className="table-row group">
                <td className="font-mono text-foreground">{c.reference}</td>
                <td className="text-muted-foreground">{c.beneficiaire}</td>
                <td className="text-muted-foreground">{c.banque}</td>
                <td className="text-muted-foreground">{formatDate(c.date_emission)}</td>
                <td className="font-semibold text-red-400">{formatCurrency(c.montant)}</td>
                <td><Badge variant={STATUT[c.statut].variant}>{STATUT[c.statut].label}</Badge></td>
                <td><Button variant="ghost" size="icon" className="w-7 h-7 text-red-400 opacity-0 group-hover:opacity-100" onClick={() => { setCheques(p => p.filter(x => x.id !== c.id)); toast.success('Supprimé') }}><Trash2 className="w-3.5 h-3.5" /></Button></td>
              </tr>
            ))}
          </tbody>
        </table>
        {cheques.length === 0 && <div className="empty-state"><Wallet className="empty-state-icon" /><p className="empty-state-title">Aucun chèque émis</p></div>}
      </div>
      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent>
          <DialogHeader><DialogTitle>Enregistrer un chèque émis</DialogTitle></DialogHeader>
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5"><label className="form-label">Référence</label><Input value={form.reference} onChange={e => setForm(p => ({ ...p, reference: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Montant (MAD)</label><Input type="number" value={form.montant} onChange={e => setForm(p => ({ ...p, montant: +e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Bénéficiaire</label><Input value={form.beneficiaire} onChange={e => setForm(p => ({ ...p, beneficiaire: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Banque</label><Input value={form.banque} onChange={e => setForm(p => ({ ...p, banque: e.target.value }))} /></div>
              <div className="space-y-1.5 col-span-2"><label className="form-label">Date émission</label><Input type="date" value={form.date_emission} onChange={e => setForm(p => ({ ...p, date_emission: e.target.value }))} /></div>
            </div>
            <div className="flex justify-end gap-3">
              <Button variant="secondary" onClick={() => setShowForm(false)}>Annuler</Button>
              <Button onClick={() => { if (!form.beneficiaire) return; setCheques(p => [{ ...form, id: Date.now().toString() }, ...p]); setShowForm(false); toast.success('Enregistré') }}>Enregistrer</Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
