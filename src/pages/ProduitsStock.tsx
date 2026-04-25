import { useState, useMemo } from 'react'
import { motion } from 'framer-motion'
import {
  Plus, Search, Trash2, Pencil, Package, Tags, Boxes, ArrowLeftRight,
  Truck, AlertTriangle, X, TrendingUp, TrendingDown, RefreshCw,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Card } from '@/components/ui/card'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter,
} from '@/components/ui/dialog'
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from '@/components/ui/select'
import {
  useStockCategories,  useCreateStockCategory,  useUpdateStockCategory,  useDeleteStockCategory,
  useStockSuppliers,   useCreateStockSupplier,  useUpdateStockSupplier,  useDeleteStockSupplier,
  useStockProducts,    useCreateStockProduct,   useUpdateStockProduct,   useDeleteStockProduct,
  useStockMovements,   useCreateStockMovement,
  useStockAlerts,
  type StockCategory, type StockSupplier, type StockProduct, type MovementType,
} from '@/hooks/useStock'
import { cn, formatCurrency } from '@/lib/utils'
import { ImportExportButtons } from '@/components/ImportExportButtons'
import { stockProductsSchema } from '@/lib/importExportSchemas'

/* ═══════════════════════════════════════════════════════════════
   PAGE — 6 onglets internes
═══════════════════════════════════════════════════════════════ */
export default function ProduitsStock() {
  const { data: alerts = [] } = useStockAlerts()

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title flex items-center gap-2">
            <Boxes className="w-6 h-6 text-blue-500" />
            Produits & Stock
          </h1>
          <p className="text-muted-foreground text-sm mt-1">
            Gestion complète du catalogue, du stock et des mouvements
          </p>
        </div>
        {alerts.length > 0 && (
          <Badge variant="destructive" className="gap-1.5 py-1.5 px-3">
            <AlertTriangle className="w-3.5 h-3.5" />
            {alerts.length} alerte{alerts.length > 1 ? 's' : ''}
          </Badge>
        )}
      </div>

      <Tabs defaultValue="products" className="space-y-4">
        <TabsList className="flex-wrap h-auto">
          <TabsTrigger value="products"    className="gap-1.5"><Package className="w-4 h-4" /> Produits</TabsTrigger>
          <TabsTrigger value="categories"  className="gap-1.5"><Tags className="w-4 h-4" /> Catégories</TabsTrigger>
          <TabsTrigger value="stock"       className="gap-1.5"><Boxes className="w-4 h-4" /> Stock</TabsTrigger>
          <TabsTrigger value="movements"   className="gap-1.5"><ArrowLeftRight className="w-4 h-4" /> Mouvements</TabsTrigger>
          <TabsTrigger value="suppliers"   className="gap-1.5"><Truck className="w-4 h-4" /> Fournisseurs</TabsTrigger>
          <TabsTrigger value="alerts"      className="gap-1.5">
            <AlertTriangle className="w-4 h-4" /> Alertes
            {alerts.length > 0 && (
              <span className="ml-1 px-1.5 rounded-full bg-red-500 text-white text-[10px] font-bold">
                {alerts.length}
              </span>
            )}
          </TabsTrigger>
        </TabsList>

        <TabsContent value="products"><ProductsTab /></TabsContent>
        <TabsContent value="categories"><CategoriesTab /></TabsContent>
        <TabsContent value="stock"><StockTab /></TabsContent>
        <TabsContent value="movements"><MovementsTab /></TabsContent>
        <TabsContent value="suppliers"><SuppliersTab /></TabsContent>
        <TabsContent value="alerts"><AlertsTab /></TabsContent>
      </Tabs>
    </div>
  )
}

/* ═══════════════════════════════════════════════════════════════
   PRODUCTS TAB
═══════════════════════════════════════════════════════════════ */
const EMPTY_PRODUCT: Partial<StockProduct> = {
  sku: '', nom: '', description: '',
  category_id: null, supplier_id: null,
  prix_achat: 0, prix_vente: 0, tva: 20,
  stock_actuel: 0, stock_minimum: 0,
  image_url: '', is_active: true,
}

function ProductsTab() {
  const [search, setSearch] = useState('')
  const [form, setForm]     = useState<(Partial<StockProduct> & { id?: string }) | null>(null)

  const { data: products = [], isLoading } = useStockProducts(search)
  const { data: categories = [] }          = useStockCategories()
  const { data: suppliers = [] }           = useStockSuppliers()
  const create = useCreateStockProduct()
  const update = useUpdateStockProduct()
  const remove = useDeleteStockProduct()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!form) return
    if (form.id) {
      await update.mutateAsync({ id: form.id, ...form })
    } else {
      await create.mutateAsync(form)
    }
    setForm(null)
  }

  return (
    <div className="space-y-4">
      <div className="flex flex-col sm:flex-row gap-3 items-stretch sm:items-center justify-between">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input
            placeholder="Rechercher par nom ou SKU…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="pl-9"
          />
        </div>
        <div className="flex items-center gap-2">
          <ImportExportButtons
            schema={stockProductsSchema}
            data={products}
            onImport={async (row) => { await create.mutateAsync(row as Partial<StockProduct>) }}
          />
          <Button size="sm" onClick={() => setForm({ ...EMPTY_PRODUCT })}>
            <Plus className="w-4 h-4" /> Nouveau produit
          </Button>
        </div>
      </div>

      {isLoading ? (
        <LoadingBlock label="Chargement des produits…" />
      ) : products.length === 0 ? (
        <EmptyState icon={<Package className="w-8 h-8" />} label="Aucun produit">
          Créez votre premier produit pour démarrer le suivi de stock.
        </EmptyState>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {products.map((p) => (
            <ProductCard
              key={p.id}
              product={p}
              onEdit={() => setForm(p)}
              onDelete={() => remove.mutate(p.id)}
            />
          ))}
        </div>
      )}

      <ProductFormDialog
        open={!!form}
        form={form}
        setForm={setForm}
        categories={categories}
        suppliers={suppliers}
        onSubmit={handleSubmit}
        loading={create.isPending || update.isPending}
      />
    </div>
  )
}

function ProductCard({
  product,
  onEdit,
  onDelete,
}: {
  product: StockProduct
  onEdit:  () => void
  onDelete:() => void
}) {
  const low = Number(product.stock_actuel) <= Number(product.stock_minimum)
  const out = Number(product.stock_actuel) <= 0

  return (
    <Card className="p-4 space-y-3">
      <div className="flex items-start justify-between gap-2">
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2 flex-wrap">
            <span className="font-semibold text-sm truncate">{product.nom}</span>
            {product.category_nom && (
              <span
                className="px-1.5 py-0.5 rounded text-[10px] font-semibold"
                style={{ background: (product.category_color ?? '#3B82F6') + '20', color: product.category_color ?? '#3B82F6' }}
              >
                {product.category_nom}
              </span>
            )}
          </div>
          <p className="text-xs text-muted-foreground mt-0.5 font-mono">{product.sku}</p>
        </div>
        <div className="flex gap-1">
          <button onClick={onEdit} className="p-1.5 rounded hover:bg-muted transition-colors" title="Modifier">
            <Pencil className="w-3.5 h-3.5 text-muted-foreground" />
          </button>
          <button onClick={onDelete} className="p-1.5 rounded hover:bg-red-50 dark:hover:bg-red-950/40 transition-colors" title="Supprimer">
            <Trash2 className="w-3.5 h-3.5 text-red-500" />
          </button>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-2 text-xs">
        <div>
          <div className="text-muted-foreground">Prix vente</div>
          <div className="font-semibold">{formatCurrency(product.prix_vente)}</div>
        </div>
        <div>
          <div className="text-muted-foreground">Stock</div>
          <div className={cn(
            'font-semibold flex items-center gap-1',
            out ? 'text-red-600' : low ? 'text-amber-600' : 'text-emerald-600',
          )}>
            {product.stock_actuel}
            {out && <Badge variant="destructive" className="text-[9px] h-4 px-1">Rupture</Badge>}
            {!out && low && <Badge className="text-[9px] h-4 px-1 bg-amber-500">Faible</Badge>}
          </div>
        </div>
      </div>
    </Card>
  )
}

function ProductFormDialog({
  open, form, setForm, categories, suppliers, onSubmit, loading,
}: {
  open:       boolean
  form:       (Partial<StockProduct> & { id?: string }) | null
  setForm:    (f: (Partial<StockProduct> & { id?: string }) | null) => void
  categories: StockCategory[]
  suppliers:  StockSupplier[]
  onSubmit:   (e: React.FormEvent) => void
  loading:    boolean
}) {
  if (!form) return null
  const set = <K extends keyof StockProduct>(k: K, v: StockProduct[K] | null) =>
    setForm({ ...form, [k]: v })

  return (
    <Dialog open={open} onOpenChange={(o) => !o && setForm(null)}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{form.id ? 'Modifier le produit' : 'Nouveau produit'}</DialogTitle>
        </DialogHeader>
        <form onSubmit={onSubmit} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Field label="Nom *">
              <Input value={form.nom ?? ''} onChange={(e) => set('nom', e.target.value)} required />
            </Field>
            <Field label="SKU" hint="laissez vide pour générer">
              <Input value={form.sku ?? ''} onChange={(e) => set('sku', e.target.value)} />
            </Field>
            <Field label="Catégorie">
              <Select
                value={form.category_id ?? 'none'}
                onValueChange={(v) => set('category_id', v === 'none' ? null : v)}
              >
                <SelectTrigger><SelectValue placeholder="—" /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="none">— Aucune —</SelectItem>
                  {categories.map((c) => (
                    <SelectItem key={c.id} value={c.id}>{c.nom}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </Field>
            <Field label="Fournisseur">
              <Select
                value={form.supplier_id ?? 'none'}
                onValueChange={(v) => set('supplier_id', v === 'none' ? null : v)}
              >
                <SelectTrigger><SelectValue placeholder="—" /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="none">— Aucun —</SelectItem>
                  {suppliers.map((s) => (
                    <SelectItem key={s.id} value={s.id}>{s.nom}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </Field>
            <Field label="Prix achat">
              <Input type="number" step="0.01" value={form.prix_achat ?? 0} onChange={(e) => set('prix_achat', Number(e.target.value))} />
            </Field>
            <Field label="Prix vente">
              <Input type="number" step="0.01" value={form.prix_vente ?? 0} onChange={(e) => set('prix_vente', Number(e.target.value))} />
            </Field>
            <Field label="TVA (%)">
              <Input type="number" step="0.01" value={form.tva ?? 20} onChange={(e) => set('tva', Number(e.target.value))} />
            </Field>
            <Field label="Image URL">
              <Input value={form.image_url ?? ''} onChange={(e) => set('image_url', e.target.value)} placeholder="https://…" />
            </Field>
            <Field label="Stock actuel">
              <Input type="number" step="0.01" value={form.stock_actuel ?? 0} onChange={(e) => set('stock_actuel', Number(e.target.value))} />
            </Field>
            <Field label="Stock minimum">
              <Input type="number" step="0.01" value={form.stock_minimum ?? 0} onChange={(e) => set('stock_minimum', Number(e.target.value))} />
            </Field>
          </div>
          <Field label="Description">
            <textarea
              className="flex min-h-[72px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
              value={form.description ?? ''}
              onChange={(e) => set('description', e.target.value)}
            />
          </Field>
          <DialogFooter>
            <Button type="button" variant="secondary" onClick={() => setForm(null)}>Annuler</Button>
            <Button type="submit" disabled={loading}>{form.id ? 'Enregistrer' : 'Créer'}</Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}

/* ═══════════════════════════════════════════════════════════════
   CATEGORIES TAB
═══════════════════════════════════════════════════════════════ */
function CategoriesTab() {
  const { data: categories = [], isLoading } = useStockCategories()
  const create = useCreateStockCategory()
  const update = useUpdateStockCategory()
  const remove = useDeleteStockCategory()
  const [form, setForm] = useState<(Partial<StockCategory> & { id?: string }) | null>(null)

  const submit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!form) return
    if (form.id) await update.mutateAsync({ id: form.id, ...form })
    else         await create.mutateAsync(form)
    setForm(null)
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <Button size="sm" onClick={() => setForm({ nom: '', color: '#3B82F6', description: '' })}>
          <Plus className="w-4 h-4" /> Nouvelle catégorie
        </Button>
      </div>

      {isLoading ? (
        <LoadingBlock label="Chargement…" />
      ) : categories.length === 0 ? (
        <EmptyState icon={<Tags className="w-8 h-8" />} label="Aucune catégorie">
          Ajoutez une catégorie pour organiser vos produits.
        </EmptyState>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3">
          {categories.map((c) => (
            <Card key={c.id} className="p-3 flex items-center justify-between gap-3">
              <div className="flex items-center gap-3 min-w-0">
                <span className="w-3 h-3 rounded-full flex-shrink-0" style={{ background: c.color ?? '#3B82F6' }} />
                <div className="min-w-0">
                  <div className="font-medium text-sm truncate">{c.nom}</div>
                  {c.description && (
                    <div className="text-[11px] text-muted-foreground truncate">{c.description}</div>
                  )}
                </div>
              </div>
              <div className="flex gap-1">
                <button onClick={() => setForm(c)} className="p-1.5 rounded hover:bg-muted" title="Modifier">
                  <Pencil className="w-3.5 h-3.5 text-muted-foreground" />
                </button>
                <button onClick={() => remove.mutate(c.id)} className="p-1.5 rounded hover:bg-red-50 dark:hover:bg-red-950/40" title="Supprimer">
                  <Trash2 className="w-3.5 h-3.5 text-red-500" />
                </button>
              </div>
            </Card>
          ))}
        </div>
      )}

      <Dialog open={!!form} onOpenChange={(o) => !o && setForm(null)}>
        {form && (
          <DialogContent>
            <DialogHeader><DialogTitle>{form.id ? 'Modifier' : 'Nouvelle catégorie'}</DialogTitle></DialogHeader>
            <form onSubmit={submit} className="space-y-4">
              <Field label="Nom *">
                <Input value={form.nom ?? ''} onChange={(e) => setForm({ ...form, nom: e.target.value })} required />
              </Field>
              <Field label="Couleur">
                <Input type="color" value={form.color ?? '#3B82F6'} onChange={(e) => setForm({ ...form, color: e.target.value })} className="h-10 w-24 p-1" />
              </Field>
              <Field label="Description">
                <Input value={form.description ?? ''} onChange={(e) => setForm({ ...form, description: e.target.value })} />
              </Field>
              <DialogFooter>
                <Button type="button" variant="secondary" onClick={() => setForm(null)}>Annuler</Button>
                <Button type="submit">{form.id ? 'Enregistrer' : 'Créer'}</Button>
              </DialogFooter>
            </form>
          </DialogContent>
        )}
      </Dialog>
    </div>
  )
}

/* ═══════════════════════════════════════════════════════════════
   STOCK TAB — vue synthèse avec action "Mouvement rapide"
═══════════════════════════════════════════════════════════════ */
function StockTab() {
  const { data: products = [], isLoading } = useStockProducts('')
  const [mvFor, setMvFor] = useState<StockProduct | null>(null)

  const totals = useMemo(() => {
    const totalStock = products.reduce((s, p) => s + Number(p.stock_actuel), 0)
    const lowCount   = products.filter((p) => Number(p.stock_actuel) <= Number(p.stock_minimum)).length
    const value      = products.reduce((s, p) => s + Number(p.stock_actuel) * Number(p.prix_achat), 0)
    return { totalStock, lowCount, value }
  }, [products])

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
        <StatCard label="Produits" value={products.length} icon={<Package className="w-4 h-4" />} />
        <StatCard label="Unités en stock" value={totals.totalStock} icon={<Boxes className="w-4 h-4" />} />
        <StatCard label="Valeur stock" value={formatCurrency(totals.value)} icon={<TrendingUp className="w-4 h-4 text-emerald-500" />} />
      </div>

      {isLoading ? (
        <LoadingBlock label="Chargement…" />
      ) : products.length === 0 ? (
        <EmptyState icon={<Boxes className="w-8 h-8" />} label="Aucun produit en stock">
          Ajoutez des produits dans l'onglet Produits pour voir l'état du stock.
        </EmptyState>
      ) : (
        <Card className="overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-muted/50 text-xs uppercase text-muted-foreground">
                <tr>
                  <th className="text-left px-3 py-2">Produit</th>
                  <th className="text-left px-3 py-2">SKU</th>
                  <th className="text-right px-3 py-2">Stock</th>
                  <th className="text-right px-3 py-2">Min</th>
                  <th className="text-right px-3 py-2">Statut</th>
                  <th className="px-3 py-2"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {products.map((p) => {
                  const out = Number(p.stock_actuel) <= 0
                  const low = Number(p.stock_actuel) <= Number(p.stock_minimum)
                  return (
                    <tr key={p.id} className="hover:bg-muted/30">
                      <td className="px-3 py-2 font-medium">{p.nom}</td>
                      <td className="px-3 py-2 font-mono text-xs text-muted-foreground">{p.sku}</td>
                      <td className="px-3 py-2 text-right font-semibold">{p.stock_actuel}</td>
                      <td className="px-3 py-2 text-right text-muted-foreground">{p.stock_minimum}</td>
                      <td className="px-3 py-2 text-right">
                        {out ? <Badge variant="destructive">Rupture</Badge>
                          : low ? <Badge className="bg-amber-500">Faible</Badge>
                          : <Badge className="bg-emerald-500">OK</Badge>}
                      </td>
                      <td className="px-3 py-2 text-right">
                        <Button size="sm" variant="ghost" onClick={() => setMvFor(p)}>
                          <ArrowLeftRight className="w-3.5 h-3.5" /> Mouvement
                        </Button>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        </Card>
      )}

      <QuickMovementDialog product={mvFor} onClose={() => setMvFor(null)} />
    </div>
  )
}

function QuickMovementDialog({ product, onClose }: { product: StockProduct | null; onClose: () => void }) {
  const [type, setType]       = useState<MovementType>('entree')
  const [qty, setQty]         = useState(1)
  const [reference, setRef]   = useState('')
  const [note, setNote]       = useState('')
  const create = useCreateStockMovement()

  const submit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!product) return
    await create.mutateAsync({ product_id: product.id, type, quantite: qty, reference, note, source: 'manual' })
    setType('entree'); setQty(1); setRef(''); setNote('')
    onClose()
  }

  return (
    <Dialog open={!!product} onOpenChange={(o) => !o && onClose()}>
      {product && (
        <DialogContent>
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <ArrowLeftRight className="w-5 h-5" /> Mouvement — {product.nom}
            </DialogTitle>
          </DialogHeader>
          <form onSubmit={submit} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <Field label="Type">
                <Select value={type} onValueChange={(v) => setType(v as MovementType)}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="entree">Entrée (+)</SelectItem>
                    <SelectItem value="sortie">Sortie (−)</SelectItem>
                    <SelectItem value="ajustement">Ajustement (=)</SelectItem>
                  </SelectContent>
                </Select>
              </Field>
              <Field label={type === 'ajustement' ? 'Nouveau stock' : 'Quantité'}>
                <Input type="number" step="0.01" value={qty} onChange={(e) => setQty(Number(e.target.value))} required />
              </Field>
            </div>
            <Field label="Référence">
              <Input value={reference} onChange={(e) => setRef(e.target.value)} placeholder="BL-001, commande #…" />
            </Field>
            <Field label="Note">
              <Input value={note} onChange={(e) => setNote(e.target.value)} />
            </Field>
            <DialogFooter>
              <Button type="button" variant="secondary" onClick={onClose}>Annuler</Button>
              <Button type="submit" disabled={create.isPending}>Enregistrer</Button>
            </DialogFooter>
          </form>
        </DialogContent>
      )}
    </Dialog>
  )
}

/* ═══════════════════════════════════════════════════════════════
   MOVEMENTS TAB
═══════════════════════════════════════════════════════════════ */
function MovementsTab() {
  const { data: movements = [], isLoading } = useStockMovements()

  return (
    <div className="space-y-4">
      {isLoading ? (
        <LoadingBlock label="Chargement…" />
      ) : movements.length === 0 ? (
        <EmptyState icon={<ArrowLeftRight className="w-8 h-8" />} label="Aucun mouvement">
          Les entrées, sorties et ajustements apparaîtront ici.
        </EmptyState>
      ) : (
        <Card className="overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-muted/50 text-xs uppercase text-muted-foreground">
                <tr>
                  <th className="text-left px-3 py-2">Date</th>
                  <th className="text-left px-3 py-2">Produit</th>
                  <th className="text-left px-3 py-2">Type</th>
                  <th className="text-right px-3 py-2">Qté</th>
                  <th className="text-left px-3 py-2">Source</th>
                  <th className="text-left px-3 py-2">Réf.</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {movements.map((m) => (
                  <tr key={m.id} className="hover:bg-muted/30">
                    <td className="px-3 py-2 text-xs text-muted-foreground whitespace-nowrap">
                      {new Date(m.created_at).toLocaleString('fr-FR')}
                    </td>
                    <td className="px-3 py-2">
                      <div className="font-medium">{m.product_nom ?? '—'}</div>
                      <div className="text-[10px] text-muted-foreground font-mono">{m.product_sku}</div>
                    </td>
                    <td className="px-3 py-2">
                      {m.type === 'entree' && (
                        <span className="inline-flex items-center gap-1 text-emerald-600 text-xs font-semibold">
                          <TrendingUp className="w-3.5 h-3.5" /> Entrée
                        </span>
                      )}
                      {m.type === 'sortie' && (
                        <span className="inline-flex items-center gap-1 text-red-600 text-xs font-semibold">
                          <TrendingDown className="w-3.5 h-3.5" /> Sortie
                        </span>
                      )}
                      {m.type === 'ajustement' && (
                        <span className="inline-flex items-center gap-1 text-blue-600 text-xs font-semibold">
                          <RefreshCw className="w-3.5 h-3.5" /> Ajustement
                        </span>
                      )}
                    </td>
                    <td className="px-3 py-2 text-right font-semibold">{m.quantite}</td>
                    <td className="px-3 py-2 text-xs">
                      {m.source === 'facture'
                        ? <Badge variant="outline" className="text-[10px]">Facture</Badge>
                        : <span className="text-muted-foreground">manuel</span>}
                    </td>
                    <td className="px-3 py-2 text-xs text-muted-foreground">{m.reference ?? '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}
    </div>
  )
}

/* ═══════════════════════════════════════════════════════════════
   SUPPLIERS TAB
═══════════════════════════════════════════════════════════════ */
function SuppliersTab() {
  const { data: suppliers = [], isLoading } = useStockSuppliers()
  const create = useCreateStockSupplier()
  const update = useUpdateStockSupplier()
  const remove = useDeleteStockSupplier()
  const [form, setForm] = useState<(Partial<StockSupplier> & { id?: string }) | null>(null)

  const submit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!form) return
    if (form.id) await update.mutateAsync({ id: form.id, ...form })
    else         await create.mutateAsync(form)
    setForm(null)
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <Button size="sm" onClick={() => setForm({ nom: '' })}>
          <Plus className="w-4 h-4" /> Nouveau fournisseur
        </Button>
      </div>
      {isLoading ? (
        <LoadingBlock label="Chargement…" />
      ) : suppliers.length === 0 ? (
        <EmptyState icon={<Truck className="w-8 h-8" />} label="Aucun fournisseur">
          Ajoutez vos fournisseurs de stock pour les rattacher aux produits.
        </EmptyState>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3">
          {suppliers.map((s) => (
            <Card key={s.id} className="p-3 flex items-start justify-between gap-3">
              <div className="min-w-0">
                <div className="font-medium text-sm">{s.nom}</div>
                {s.email     && <div className="text-xs text-muted-foreground truncate">{s.email}</div>}
                {s.telephone && <div className="text-xs text-muted-foreground">{s.telephone}</div>}
                {s.adresse   && <div className="text-xs text-muted-foreground truncate">{s.adresse}</div>}
              </div>
              <div className="flex gap-1 flex-shrink-0">
                <button onClick={() => setForm(s)} className="p-1.5 rounded hover:bg-muted" title="Modifier">
                  <Pencil className="w-3.5 h-3.5 text-muted-foreground" />
                </button>
                <button onClick={() => remove.mutate(s.id)} className="p-1.5 rounded hover:bg-red-50 dark:hover:bg-red-950/40" title="Supprimer">
                  <Trash2 className="w-3.5 h-3.5 text-red-500" />
                </button>
              </div>
            </Card>
          ))}
        </div>
      )}

      <Dialog open={!!form} onOpenChange={(o) => !o && setForm(null)}>
        {form && (
          <DialogContent>
            <DialogHeader><DialogTitle>{form.id ? 'Modifier' : 'Nouveau fournisseur'}</DialogTitle></DialogHeader>
            <form onSubmit={submit} className="space-y-4">
              <Field label="Nom *">
                <Input value={form.nom ?? ''} onChange={(e) => setForm({ ...form, nom: e.target.value })} required />
              </Field>
              <Field label="Email">
                <Input type="email" value={form.email ?? ''} onChange={(e) => setForm({ ...form, email: e.target.value })} />
              </Field>
              <Field label="Téléphone">
                <Input value={form.telephone ?? ''} onChange={(e) => setForm({ ...form, telephone: e.target.value })} />
              </Field>
              <Field label="Adresse">
                <Input value={form.adresse ?? ''} onChange={(e) => setForm({ ...form, adresse: e.target.value })} />
              </Field>
              <Field label="Notes">
                <Input value={form.notes ?? ''} onChange={(e) => setForm({ ...form, notes: e.target.value })} />
              </Field>
              <DialogFooter>
                <Button type="button" variant="secondary" onClick={() => setForm(null)}>Annuler</Button>
                <Button type="submit">{form.id ? 'Enregistrer' : 'Créer'}</Button>
              </DialogFooter>
            </form>
          </DialogContent>
        )}
      </Dialog>
    </div>
  )
}

/* ═══════════════════════════════════════════════════════════════
   ALERTS TAB
═══════════════════════════════════════════════════════════════ */
function AlertsTab() {
  const { data: alerts = [], isLoading } = useStockAlerts()

  if (isLoading) return <LoadingBlock label="Chargement…" />
  if (alerts.length === 0) {
    return (
      <EmptyState icon={<AlertTriangle className="w-8 h-8 text-emerald-500" />} label="Tout est OK">
        Aucun produit en rupture ou stock faible.
      </EmptyState>
    )
  }

  return (
    <div className="space-y-3">
      {alerts.map((a) => (
        <Card key={a.id} className={cn(
          'p-4 flex items-center justify-between gap-3 border-l-4',
          a.level === 'rupture' ? 'border-l-red-500' : 'border-l-amber-500',
        )}>
          <div className="flex items-center gap-3 min-w-0">
            <AlertTriangle className={cn(
              'w-5 h-5 flex-shrink-0',
              a.level === 'rupture' ? 'text-red-500' : 'text-amber-500',
            )} />
            <div className="min-w-0">
              <div className="font-medium text-sm truncate">{a.nom}</div>
              <div className="text-xs text-muted-foreground font-mono">{a.sku}</div>
            </div>
          </div>
          <div className="text-right flex-shrink-0">
            <div className={cn(
              'text-lg font-bold',
              a.level === 'rupture' ? 'text-red-600' : 'text-amber-600',
            )}>
              {a.stock_actuel}
            </div>
            <div className="text-[10px] text-muted-foreground">min. {a.stock_minimum}</div>
          </div>
        </Card>
      ))}
    </div>
  )
}

/* ═══════════════════════════════════════════════════════════════
   Shared UI bits
═══════════════════════════════════════════════════════════════ */
function Field({ label, hint, children }: { label: string; hint?: string; children: React.ReactNode }) {
  return (
    <div className="space-y-1.5">
      <label className="text-xs font-medium text-muted-foreground flex items-center gap-2">
        {label}
        {hint && <span className="text-[10px] italic text-muted-foreground/70">— {hint}</span>}
      </label>
      {children}
    </div>
  )
}

function StatCard({ label, value, icon }: { label: string; value: React.ReactNode; icon: React.ReactNode }) {
  return (
    <Card className="p-4">
      <div className="flex items-center justify-between">
        <span className="text-xs text-muted-foreground">{label}</span>
        <span className="text-muted-foreground">{icon}</span>
      </div>
      <div className="text-xl font-bold mt-1">{value}</div>
    </Card>
  )
}

function LoadingBlock({ label }: { label: string }) {
  return (
    <div className="flex items-center gap-3 text-sm text-muted-foreground py-10 justify-center">
      <div className="w-5 h-5 rounded-full border-2 border-blue-500 border-t-transparent animate-spin" />
      {label}
    </div>
  )
}

function EmptyState({ icon, label, children }: { icon: React.ReactNode; label: string; children?: React.ReactNode }) {
  return (
    <Card className="p-10 text-center">
      <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-muted mb-3 text-muted-foreground">
        {icon}
      </div>
      <h3 className="font-semibold">{label}</h3>
      {children && <p className="text-sm text-muted-foreground mt-1 max-w-md mx-auto">{children}</p>}
    </Card>
  )
}
