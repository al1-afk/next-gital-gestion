import { useState } from 'react'
import { motion } from 'framer-motion'
import { Plus, Package, Search, Edit2, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { formatCurrency } from '@/lib/utils'
import { toast } from 'sonner'

interface Produit { id: string; nom: string; description: string; prix_ht: number; tva: number; type: 'produit' | 'service'; unite: string }

const MOCK: Produit[] = [
  { id: '1', nom: 'Création Site Web Vitrine', description: 'Site web professionnel 5 pages responsive', prix_ht: 8333.33, tva: 20, type: 'service', unite: 'projet' },
  { id: '2', nom: 'Refonte Complète E-commerce', description: 'Plateforme e-commerce avec paiement en ligne', prix_ht: 20833.33, tva: 20, type: 'service', unite: 'projet' },
  { id: '3', nom: 'Application Mobile (iOS + Android)', description: 'App native React Native', prix_ht: 41666.67, tva: 20, type: 'service', unite: 'projet' },
  { id: '4', nom: 'Pack SEO Mensuel', description: 'Optimisation référencement naturel', prix_ht: 2500, tva: 20, type: 'service', unite: 'mois' },
  { id: '5', nom: 'Maintenance & Support', description: 'Support technique 20h/mois', prix_ht: 3000, tva: 20, type: 'service', unite: 'mois' },
  { id: '6', nom: 'CRM Personnalisé', description: 'Solution CRM sur mesure', prix_ht: 25000, tva: 20, type: 'service', unite: 'projet' },
]

export default function Produits() {
  const [produits, setProduits] = useState(MOCK)
  const [search, setSearch] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ nom: '', description: '', prix_ht: 0, tva: 20, type: 'service' as 'produit' | 'service', unite: 'projet' })

  const filtered = produits.filter(p => !search || p.nom.toLowerCase().includes(search.toLowerCase()))

  const save = () => {
    if (!form.nom) return
    setProduits(prev => [{ ...form, id: Date.now().toString() }, ...prev])
    setShowForm(false)
    toast.success('Produit ajouté')
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title">Produits & Services</h1>
          <p className="text-muted-foreground text-sm mt-1">{produits.length} articles dans le catalogue</p>
        </div>
        <Button size="sm" onClick={() => setShowForm(true)}><Plus className="w-4 h-4" /> Ajouter</Button>
      </div>

      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
        <Input placeholder="Rechercher..." value={search} onChange={e => setSearch(e.target.value)} className="pl-9" />
      </div>

      <div className="card overflow-hidden">
        <table className="w-full">
          <thead><tr className="table-header"><th>Nom</th><th>Description</th><th>Type</th><th>Prix HT</th><th>TVA</th><th>Prix TTC</th><th></th></tr></thead>
          <tbody>
            {filtered.map(p => (
              <tr key={p.id} className="table-row group">
                <td className="font-medium text-foreground">{p.nom}</td>
                <td className="text-muted-foreground text-sm max-w-xs truncate">{p.description}</td>
                <td><Badge variant={p.type === 'service' ? 'default' : 'secondary'}>{p.type}</Badge></td>
                <td className="text-muted-foreground">{formatCurrency(p.prix_ht)}</td>
                <td className="text-muted-foreground">{p.tva}%</td>
                <td className="font-semibold text-foreground">{formatCurrency(p.prix_ht * (1 + p.tva / 100))}</td>
                <td>
                  <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                    <Button variant="ghost" size="icon" className="w-7 h-7 text-red-400" onClick={() => { setProduits(prev => prev.filter(x => x.id !== p.id)); toast.success('Supprimé') }}>
                      <Trash2 className="w-3.5 h-3.5" />
                    </Button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 && <div className="empty-state"><Package className="empty-state-icon" /><p className="empty-state-title">Aucun produit</p></div>}
      </div>

      <Dialog open={showForm} onOpenChange={setShowForm}>
        <DialogContent>
          <DialogHeader><DialogTitle>Nouveau produit / service</DialogTitle></DialogHeader>
          <div className="space-y-4">
            <div className="space-y-1.5"><label className="form-label">Nom *</label><Input value={form.nom} onChange={e => setForm(p => ({ ...p, nom: e.target.value }))} /></div>
            <div className="space-y-1.5"><label className="form-label">Description</label><textarea value={form.description} onChange={e => setForm(p => ({ ...p, description: e.target.value }))} className="input-field resize-none h-16" /></div>
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5"><label className="form-label">Prix HT (MAD)</label><Input type="number" step="0.01" value={form.prix_ht} onChange={e => setForm(p => ({ ...p, prix_ht: +e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">TVA (%)</label>
                <Select value={String(form.tva)} onValueChange={v => setForm(p => ({ ...p, tva: +v }))}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>{['0','7','10','14','20'].map(v => <SelectItem key={v} value={v}>{v}%</SelectItem>)}</SelectContent>
                </Select>
              </div>
              <div className="space-y-1.5"><label className="form-label">Type</label>
                <Select value={form.type} onValueChange={v => setForm(p => ({ ...p, type: v as 'produit' | 'service' }))}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent><SelectItem value="service">Service</SelectItem><SelectItem value="produit">Produit</SelectItem></SelectContent>
                </Select>
              </div>
              <div className="space-y-1.5"><label className="form-label">Unité</label><Input value={form.unite} onChange={e => setForm(p => ({ ...p, unite: e.target.value }))} placeholder="projet, mois, heure..." /></div>
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
