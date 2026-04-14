import { useState, useMemo } from 'react'
import { Plus, Search, FileSignature, Download, Edit2, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { formatCurrency, formatDate } from '@/lib/utils'
import { toast } from 'sonner'

interface Contrat {
  id: string; numero: string; client: string; objet: string; montant: number
  date_debut: string; date_fin: string; statut: 'actif' | 'expire' | 'resilie' | 'brouillon'
}

const MOCK: Contrat[] = [
  { id: '1', numero: 'CTR-2026-001', client: 'Hôtel Atlas', objet: 'Maintenance annuelle site web + CRM', montant: 32000, date_debut: '2026-01-01', date_fin: '2026-12-31', statut: 'actif' },
  { id: '2', numero: 'CTR-2026-002', client: 'PharmaTech', objet: 'Développement application mobile', montant: 85000, date_debut: '2026-03-01', date_fin: '2026-09-30', statut: 'actif' },
  { id: '3', numero: 'CTR-2025-008', client: 'Mode & Co', objet: 'Refonte site e-commerce', montant: 24000, date_debut: '2025-06-01', date_fin: '2025-12-31', statut: 'expire' },
]

const STATUT_CONFIG = {
  actif:    { label: 'Actif',    variant: 'success' as const },
  expire:   { label: 'Expiré',  variant: 'secondary' as const },
  resilie:  { label: 'Résilié', variant: 'destructive' as const },
  brouillon:{ label: 'Brouillon', variant: 'secondary' as const },
}

export default function Contrats() {
  const [contrats, setContrats] = useState(MOCK)
  const [search, setSearch] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ numero: '', client: '', objet: '', montant: 0, date_debut: '', date_fin: '', statut: 'brouillon' as Contrat['statut'] })

  const filtered = useMemo(() => contrats.filter(c => !search || [c.numero, c.client, c.objet].some(x => x.toLowerCase().includes(search.toLowerCase()))), [contrats, search])
  const stats = useMemo(() => ({
    actifs: contrats.filter(c => c.statut === 'actif').length,
    valeur: contrats.filter(c => c.statut === 'actif').reduce((s, c) => s + c.montant, 0),
  }), [contrats])

  const save = () => {
    if (!form.numero || !form.client) return
    setContrats(prev => [{ ...form, id: Date.now().toString() }, ...prev])
    setShowForm(false)
    toast.success('Contrat créé')
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Contrats</h1>
          <p className="text-muted-foreground text-sm mt-1">{stats.actifs} actifs · {formatCurrency(stats.valeur)} engagés</p>
        </div>
        <Button size="sm" onClick={() => setShowForm(true)}><Plus className="w-4 h-4" /> Nouveau contrat</Button>
      </div>

      <div className="grid grid-cols-3 gap-4">
        <div className="card p-4"><p className="text-xs text-muted-foreground uppercase tracking-wider mb-1">Contrats actifs</p><p className="text-xl font-bold text-emerald-400">{stats.actifs}</p></div>
        <div className="card p-4"><p className="text-xs text-muted-foreground uppercase tracking-wider mb-1">Valeur totale</p><p className="text-xl font-bold text-foreground">{formatCurrency(stats.valeur)}</p></div>
        <div className="card p-4"><p className="text-xs text-muted-foreground uppercase tracking-wider mb-1">Expirés</p><p className="text-xl font-bold text-muted-foreground">{contrats.filter(c => c.statut === 'expire').length}</p></div>
      </div>

      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
        <Input placeholder="Rechercher..." value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
      </div>

      <div className="card overflow-hidden">
        <table className="w-full">
          <thead><tr className="table-header"><th>N° Contrat</th><th>Client</th><th>Objet</th><th>Montant</th><th>Période</th><th>Statut</th><th></th></tr></thead>
          <tbody>
            {filtered.map(c => (
              <tr key={c.id} className="table-row group">
                <td className="font-mono font-medium text-foreground">{c.numero}</td>
                <td className="text-muted-foreground">{c.client}</td>
                <td className="text-muted-foreground text-sm max-w-xs truncate">{c.objet}</td>
                <td className="font-semibold text-foreground">{formatCurrency(c.montant)}</td>
                <td className="text-muted-foreground text-sm">{formatDate(c.date_debut)} → {formatDate(c.date_fin)}</td>
                <td><Badge variant={STATUT_CONFIG[c.statut].variant}>{STATUT_CONFIG[c.statut].label}</Badge></td>
                <td>
                  <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                    <Button variant="ghost" size="icon" className="w-7 h-7"><Download className="w-3.5 h-3.5 text-blue-400" /></Button>
                    <Button variant="ghost" size="icon" className="w-7 h-7 text-red-400" onClick={() => { setContrats(prev => prev.filter(x => x.id !== c.id)); toast.success('Supprimé') }}>
                      <Trash2 className="w-3.5 h-3.5" />
                    </Button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 && <div className="empty-state"><FileSignature className="empty-state-icon" /><p className="empty-state-title">Aucun contrat</p></div>}
      </div>

      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent className="max-w-lg">
          <DialogHeader><DialogTitle>Nouveau contrat</DialogTitle></DialogHeader>
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5"><label className="form-label">N° Contrat</label><Input value={form.numero} onChange={e => setForm(p => ({ ...p, numero: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Client</label><Input value={form.client} onChange={e => setForm(p => ({ ...p, client: e.target.value }))} /></div>
              <div className="space-y-1.5 col-span-2"><label className="form-label">Objet</label><Input value={form.objet} onChange={e => setForm(p => ({ ...p, objet: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Montant (MAD)</label><Input type="number" value={form.montant} onChange={e => setForm(p => ({ ...p, montant: +e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Statut</label>
                <Select value={form.statut} onValueChange={v => setForm(p => ({ ...p, statut: v as Contrat['statut'] }))}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>{Object.entries(STATUT_CONFIG).map(([k, v]) => <SelectItem key={k} value={k}>{v.label}</SelectItem>)}</SelectContent>
                </Select>
              </div>
              <div className="space-y-1.5"><label className="form-label">Date début</label><Input type="date" value={form.date_debut} onChange={e => setForm(p => ({ ...p, date_debut: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Date fin</label><Input type="date" value={form.date_fin} onChange={e => setForm(p => ({ ...p, date_fin: e.target.value }))} /></div>
            </div>
            <div className="flex justify-end gap-3">
              <Button variant="secondary" onClick={() => setShowForm(false)}>Annuler</Button>
              <Button onClick={save}>Créer</Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
