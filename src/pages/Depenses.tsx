import { useState, useMemo } from 'react'
import { motion } from 'framer-motion'
import { Plus, Search, DollarSign, Trash2, Loader2, TrendingDown } from 'lucide-react'
import { useDepenses, useCreateDepense, useDeleteDepense, type Depense } from '@/hooks/useDepenses'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'
import { formatCurrency, formatDate, EXPENSE_CATEGORIES } from '@/lib/utils'

const CAT_COLORS: Record<string, string> = {
  nourriture: '#ef4444',
  transport: '#f97316',
  logement: '#8b5cf6',
  sante: '#06b6d4',
  loisirs: '#f59e0b',
  shopping: '#ec4899',
  factures: '#3b82f6',
  education: '#10b981',
  logiciels: '#6366f1',
  autre: '#64748b',
}

function DepenseForm({ onClose }: { onClose: () => void }) {
  const create = useCreateDepense()
  const [form, setForm] = useState({
    description: '',
    montant: 0,
    categorie: 'autre',
    type: 'professionnel' as 'personnel' | 'professionnel',
    date_depense: new Date().toISOString().slice(0, 10),
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    await create.mutateAsync(form)
    onClose()
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-1.5">
        <label className="form-label">Description *</label>
        <Input value={form.description} onChange={e => setForm(p => ({ ...p, description: e.target.value }))} required placeholder="Ex: Achat matériel bureau" />
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-1.5">
          <label className="form-label">Montant (MAD) *</label>
          <Input type="number" step="0.01" value={form.montant} onChange={e => setForm(p => ({ ...p, montant: +e.target.value }))} required />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Date</label>
          <Input type="date" value={form.date_depense} onChange={e => setForm(p => ({ ...p, date_depense: e.target.value }))} />
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Catégorie</label>
          <Select value={form.categorie} onValueChange={v => setForm(p => ({ ...p, categorie: v }))}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>
              {EXPENSE_CATEGORIES.map(c => <SelectItem key={c} value={c}>{c.charAt(0).toUpperCase() + c.slice(1)}</SelectItem>)}
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-1.5">
          <label className="form-label">Type</label>
          <Select value={form.type} onValueChange={v => setForm(p => ({ ...p, type: v as 'personnel' | 'professionnel' }))}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="professionnel">Professionnel</SelectItem>
              <SelectItem value="personnel">Personnel</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>
      <div className="flex items-center justify-end gap-3 pt-2">
        <Button type="button" variant="secondary" onClick={onClose}>Annuler</Button>
        <Button type="submit" disabled={create.isPending}>
          {create.isPending && <Loader2 className="w-4 h-4 animate-spin" />}
          Ajouter
        </Button>
      </div>
    </form>
  )
}

export default function Depenses() {
  const { data: depenses = [], isLoading } = useDepenses()
  const deleteDepense = useDeleteDepense()
  const [search, setSearch] = useState('')
  const [filterType, setFilterType] = useState('all')
  const [showForm, setShowForm] = useState(false)

  const filtered = useMemo(() =>
    depenses.filter(d => {
      const matchSearch = !search || d.description.toLowerCase().includes(search.toLowerCase())
      const matchType = filterType === 'all' || d.type === filterType
      return matchSearch && matchType
    })
  , [depenses, search, filterType])

  const stats = useMemo(() => {
    const total = filtered.reduce((s, d) => s + d.montant, 0)
    const pro = filtered.filter(d => d.type === 'professionnel').reduce((s, d) => s + d.montant, 0)
    const perso = filtered.filter(d => d.type === 'personnel').reduce((s, d) => s + d.montant, 0)
    const byCat = EXPENSE_CATEGORIES.map(cat => ({
      cat, value: filtered.filter(d => d.categorie === cat).reduce((s, d) => s + d.montant, 0)
    })).filter(x => x.value > 0)
    return { total, pro, perso, byCat }
  }, [filtered])

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Dépenses</h1>
          <p className="text-muted-foreground text-sm mt-1">{depenses.length} dépenses · {formatCurrency(depenses.reduce((s, d) => s + d.montant, 0))} total</p>
        </div>
        <Button size="sm" onClick={() => setShowForm(true)}>
          <Plus className="w-4 h-4" /> Nouvelle dépense
        </Button>
      </div>

      <div className="grid grid-cols-3 gap-4">
        <div className="card p-4">
          <p className="text-xs text-muted-foreground uppercase tracking-wider mb-1">Total</p>
          <p className="text-xl font-bold text-foreground">{formatCurrency(stats.total)}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-muted-foreground uppercase tracking-wider mb-1">Professionnel</p>
          <p className="text-xl font-bold text-blue-400">{formatCurrency(stats.pro)}</p>
        </div>
        <div className="card p-4">
          <p className="text-xs text-muted-foreground uppercase tracking-wider mb-1">Personnel</p>
          <p className="text-xl font-bold text-purple-400">{formatCurrency(stats.perso)}</p>
        </div>
      </div>

      {/* Chart */}
      {stats.byCat.length > 0 && (
        <div className="card p-5">
          <h2 className="section-title mb-4">Répartition par catégorie</h2>
          <ResponsiveContainer width="100%" height={200}>
            <BarChart data={stats.byCat} margin={{ top: 5, right: 5, bottom: 5, left: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" />
              <XAxis dataKey="cat" tick={{ fill: '#64748b', fontSize: 11 }} />
              <YAxis tick={{ fill: '#64748b', fontSize: 11 }} tickFormatter={v => `${v/1000}k`} />
              <Tooltip
                contentStyle={{ backgroundColor: '#0f172a', border: '1px solid #1e293b', borderRadius: 8 }}
                formatter={(v: any) => [`${v.toLocaleString('fr-FR')} MAD`]}
              />
              <Bar dataKey="value" radius={[4, 4, 0, 0]}>
                {stats.byCat.map((entry, i) => (
                  <Cell key={i} fill={CAT_COLORS[entry.cat] || '#64748b'} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}

      <div className="flex items-center gap-3">
        <div className="relative flex-1 min-w-48">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input placeholder="Rechercher..." value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
        </div>
        <Select value={filterType} onValueChange={setFilterType}>
          <SelectTrigger className="w-44"><SelectValue /></SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Tous types</SelectItem>
            <SelectItem value="professionnel">Professionnel</SelectItem>
            <SelectItem value="personnel">Personnel</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <div className="card overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="table-header">
              <th>Description</th>
              <th>Catégorie</th>
              <th>Type</th>
              <th>Date</th>
              <th>Montant</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan={6} className="text-center py-12"><Loader2 className="w-6 h-6 animate-spin text-blue-400 mx-auto" /></td></tr>
            ) : filtered.map(d => (
              <tr key={d.id} className="table-row group">
                <td className="text-foreground font-medium">{d.description}</td>
                <td>
                  <span className="flex items-center gap-1.5">
                    <div className="w-2 h-2 rounded-full" style={{ backgroundColor: CAT_COLORS[d.categorie] || '#64748b' }} />
                    <span className="text-muted-foreground text-sm capitalize">{d.categorie}</span>
                  </span>
                </td>
                <td>
                  <Badge variant={d.type === 'professionnel' ? 'default' : 'purple'}>
                    {d.type === 'professionnel' ? 'Pro' : 'Perso'}
                  </Badge>
                </td>
                <td className="text-muted-foreground">{formatDate(d.date_depense)}</td>
                <td className="font-semibold text-red-400">{formatCurrency(d.montant)}</td>
                <td>
                  <Button variant="ghost" size="icon" className="w-7 h-7 text-red-400 opacity-0 group-hover:opacity-100"
                    onClick={() => { if (confirm('Supprimer ?')) deleteDepense.mutate(d.id) }}>
                    <Trash2 className="w-3.5 h-3.5" />
                  </Button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {!isLoading && filtered.length === 0 && (
          <div className="empty-state">
            <TrendingDown className="empty-state-icon" />
            <p className="empty-state-title">Aucune dépense trouvée</p>
          </div>
        )}
      </div>

      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent>
          <DialogHeader><DialogTitle>Nouvelle dépense</DialogTitle></DialogHeader>
          <DepenseForm onClose={() => setShowForm(false)} />
        </DialogContent>
      </Dialog>
    </div>
  )
}
