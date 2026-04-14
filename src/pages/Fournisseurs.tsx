import { useState, useMemo } from 'react'
import { motion } from 'framer-motion'
import { Plus, Search, Building2, Mail, Phone, Edit2, Trash2, Loader2 } from 'lucide-react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { getInitials } from '@/lib/utils'
import { toast } from 'sonner'

interface Fournisseur {
  id: string; nom: string; email?: string; telephone?: string; adresse?: string; categorie?: string; notes?: string
}

const MOCK: Fournisseur[] = [
  { id: '1', nom: 'Adobe Inc.', email: 'support@adobe.com', telephone: '+1-800-833-6687', categorie: 'Logiciels', notes: 'CC + Acrobat' },
  { id: '2', nom: 'Contabo GmbH', email: 'support@contabo.com', telephone: '+49 89 21680', categorie: 'Hébergement', notes: 'VPS Principal' },
  { id: '3', nom: 'Maroc Telecom', email: 'service@iam.ma', telephone: '0800 002 700', categorie: 'Télécom', notes: 'Fibre + mobile' },
  { id: '4', nom: 'Bureau Office MA', email: 'info@bureau-office.ma', telephone: '0522 123 456', categorie: 'Fournitures', notes: 'Papeterie, matériel' },
]

const FOURNISSEURS_KEY = 'fournisseurs'

export default function Fournisseurs() {
  const [fournisseurs, setFournisseurs] = useState(MOCK)
  const [search, setSearch] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [editing, setEditing] = useState<Fournisseur | undefined>()
  const [form, setForm] = useState({ nom: '', email: '', telephone: '', adresse: '', categorie: '', notes: '' })

  const filtered = useMemo(() =>
    fournisseurs.filter(f => !search || [f.nom, f.email, f.categorie].some(x => x?.toLowerCase().includes(search.toLowerCase())))
  , [fournisseurs, search])

  const openAdd = () => { setEditing(undefined); setForm({ nom: '', email: '', telephone: '', adresse: '', categorie: '', notes: '' }); setShowForm(true) }
  const openEdit = (f: Fournisseur) => { setEditing(f); setForm({ nom: f.nom, email: f.email || '', telephone: f.telephone || '', adresse: f.adresse || '', categorie: f.categorie || '', notes: f.notes || '' }); setShowForm(true) }

  const save = () => {
    if (!form.nom) return
    if (editing) {
      setFournisseurs(prev => prev.map(f => f.id === editing.id ? { ...f, ...form } : f))
      toast.success('Fournisseur mis à jour')
    } else {
      setFournisseurs(prev => [{ ...form, id: Date.now().toString() }, ...prev])
      toast.success('Fournisseur ajouté')
    }
    setShowForm(false)
  }

  const COLORS: Record<string, string> = {
    Logiciels: 'text-blue-400 bg-blue-500/20',
    Hébergement: 'text-purple-400 bg-purple-500/20',
    Télécom: 'text-cyan-400 bg-cyan-500/20',
    Fournitures: 'text-yellow-400 bg-yellow-500/20',
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Fournisseurs</h1>
          <p className="text-muted-foreground text-sm mt-1">{fournisseurs.length} fournisseurs</p>
        </div>
        <Button size="sm" onClick={openAdd}><Plus className="w-4 h-4" /> Ajouter</Button>
      </div>

      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
        <Input placeholder="Rechercher..." value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
        {filtered.map((f, i) => (
          <motion.div key={f.id} initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.04 }}
            className="card p-5 hover:border-blue-500/30 transition-all group">
            <div className="flex items-start gap-3">
              <div className="w-12 h-12 rounded-xl bg-muted border border-border flex items-center justify-center flex-shrink-0">
                <span className="text-muted-foreground font-bold text-sm">{getInitials(f.nom)}</span>
              </div>
              <div className="flex-1 min-w-0">
                <h3 className="font-semibold text-foreground truncate">{f.nom}</h3>
                {f.categorie && <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${COLORS[f.categorie] || 'text-muted-foreground bg-muted'}`}>{f.categorie}</span>}
              </div>
              <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                <Button variant="ghost" size="icon" className="w-7 h-7" onClick={() => openEdit(f)}><Edit2 className="w-3.5 h-3.5" /></Button>
                <Button variant="ghost" size="icon" className="w-7 h-7 text-red-400" onClick={() => { setFournisseurs(prev => prev.filter(x => x.id !== f.id)); toast.success('Supprimé') }}>
                  <Trash2 className="w-3.5 h-3.5" />
                </Button>
              </div>
            </div>
            <div className="mt-3 space-y-1.5">
              {f.email && <div className="flex items-center gap-2 text-xs text-muted-foreground"><Mail className="w-3.5 h-3.5 text-slate-600" />{f.email}</div>}
              {f.telephone && <div className="flex items-center gap-2 text-xs text-muted-foreground"><Phone className="w-3.5 h-3.5 text-slate-600" />{f.telephone}</div>}
              {f.notes && <p className="text-xs text-muted-foreground mt-2 pt-2 border-t border-border">{f.notes}</p>}
            </div>
          </motion.div>
        ))}
        {filtered.length === 0 && <div className="col-span-full empty-state"><Building2 className="empty-state-icon" /><p className="empty-state-title">Aucun fournisseur</p></div>}
      </div>

      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent>
          <DialogHeader><DialogTitle>{editing ? 'Modifier le fournisseur' : 'Nouveau fournisseur'}</DialogTitle></DialogHeader>
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5 col-span-2"><label className="form-label">Nom *</label><Input value={form.nom} onChange={e => setForm(p => ({ ...p, nom: e.target.value }))} required /></div>
              <div className="space-y-1.5"><label className="form-label">Email</label><Input value={form.email} onChange={e => setForm(p => ({ ...p, email: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Téléphone</label><Input value={form.telephone} onChange={e => setForm(p => ({ ...p, telephone: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Catégorie</label><Input value={form.categorie} onChange={e => setForm(p => ({ ...p, categorie: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Adresse</label><Input value={form.adresse} onChange={e => setForm(p => ({ ...p, adresse: e.target.value }))} /></div>
            </div>
            <div className="space-y-1.5"><label className="form-label">Notes</label>
              <textarea value={form.notes} onChange={e => setForm(p => ({ ...p, notes: e.target.value }))} className="input-field resize-none h-16" /></div>
            <div className="flex justify-end gap-3">
              <Button variant="secondary" onClick={() => setShowForm(false)}>Annuler</Button>
              <Button onClick={save}>{editing ? 'Mettre à jour' : 'Ajouter'}</Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
