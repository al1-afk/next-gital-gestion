import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { api } from '@/lib/api'
import { currentTenantIdForCache } from '@/lib/authToken'

/* ── Types ──────────────────────────────────────────────────── */

export interface StockCategory {
  id:          string
  nom:         string
  description: string | null
  color:       string | null
  created_at:  string
  updated_at:  string
}

export interface StockSupplier {
  id:         string
  nom:        string
  email:      string | null
  telephone:  string | null
  adresse:    string | null
  notes:      string | null
  created_at: string
  updated_at: string
}

export interface StockProduct {
  id:             string
  sku:            string
  nom:            string
  description:    string | null
  category_id:    string | null
  supplier_id:    string | null
  prix_achat:     number
  prix_vente:     number
  tva:            number
  stock_actuel:   number
  stock_minimum:  number
  image_url:      string | null
  is_active:      boolean
  created_at:     string
  updated_at:     string
  /* Joined, present on list endpoint only */
  category_nom?:   string | null
  category_color?: string | null
  supplier_nom?:   string | null
}

export type MovementType = 'entree' | 'sortie' | 'ajustement'

export interface StockMovement {
  id:         string
  product_id: string
  type:       MovementType
  quantite:   number
  reference:  string | null
  note:       string | null
  source:     'manual' | 'facture' | 'ajustement_auto'
  source_id:  string | null
  created_at: string
  /* Joined */
  product_nom?: string | null
  product_sku?: string | null
}

export interface StockAlert {
  id:            string
  sku:           string
  nom:           string
  stock_actuel:  number
  stock_minimum: number
  level:         'rupture' | 'faible'
}

/* ── Query keys — tenant-scoped so switching accounts invalidates ── */
const tk = (...k: (string | number | null)[]) => ['stock', currentTenantIdForCache(), ...k] as const

/* ═══════════════════════════════════════════════════════════════
   CATEGORIES
═══════════════════════════════════════════════════════════════ */
export function useStockCategories() {
  return useQuery<StockCategory[]>({
    queryKey: tk('categories'),
    queryFn:  () => api.get('/api/stock/categories'),
    staleTime: 1000 * 60 * 5,
  })
}
export function useCreateStockCategory() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: Partial<StockCategory>) =>
      api.post<StockCategory>('/api/stock/categories', data),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['stock'] }); toast.success('Catégorie créée') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}
export function useUpdateStockCategory() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<StockCategory> & { id: string }) =>
      api.patch<StockCategory>(`/api/stock/categories/${id}`, data),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['stock'] }); toast.success('Catégorie modifiée') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}
export function useDeleteStockCategory() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => api.delete(`/api/stock/categories/${id}`),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['stock'] }); toast.success('Catégorie supprimée') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/* ═══════════════════════════════════════════════════════════════
   SUPPLIERS
═══════════════════════════════════════════════════════════════ */
export function useStockSuppliers() {
  return useQuery<StockSupplier[]>({
    queryKey: tk('suppliers'),
    queryFn:  () => api.get('/api/stock/suppliers'),
    staleTime: 1000 * 60 * 5,
  })
}
export function useCreateStockSupplier() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: Partial<StockSupplier>) =>
      api.post<StockSupplier>('/api/stock/suppliers', data),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['stock'] }); toast.success('Fournisseur créé') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}
export function useUpdateStockSupplier() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<StockSupplier> & { id: string }) =>
      api.patch<StockSupplier>(`/api/stock/suppliers/${id}`, data),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['stock'] }); toast.success('Fournisseur modifié') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}
export function useDeleteStockSupplier() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => api.delete(`/api/stock/suppliers/${id}`),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['stock'] }); toast.success('Fournisseur supprimé') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/* ═══════════════════════════════════════════════════════════════
   PRODUCTS
═══════════════════════════════════════════════════════════════ */
export function useStockProducts(search = '') {
  return useQuery<StockProduct[]>({
    queryKey: tk('products', search),
    queryFn:  () => api.get(`/api/stock/products?search=${encodeURIComponent(search)}`),
    staleTime: 1000 * 60 * 2,
  })
}
export function useCreateStockProduct() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: Partial<StockProduct>) =>
      api.post<StockProduct>('/api/stock/products', data),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['stock'] }); toast.success('Produit créé') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}
export function useUpdateStockProduct() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<StockProduct> & { id: string }) =>
      api.patch<StockProduct>(`/api/stock/products/${id}`, data),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['stock'] }); toast.success('Produit modifié') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}
export function useDeleteStockProduct() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => api.delete(`/api/stock/products/${id}`),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['stock'] }); toast.success('Produit supprimé') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/* ═══════════════════════════════════════════════════════════════
   MOVEMENTS
═══════════════════════════════════════════════════════════════ */
export function useStockMovements(productId?: string) {
  return useQuery<StockMovement[]>({
    queryKey: tk('movements', productId ?? null),
    queryFn:  () => api.get(
      `/api/stock/movements${productId ? `?product_id=${productId}` : ''}`,
    ),
    staleTime: 1000 * 60,
  })
}
export function useCreateStockMovement() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: Partial<StockMovement>) =>
      api.post<StockMovement>('/api/stock/movements', data),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['stock'] }); toast.success('Mouvement enregistré') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/* ═══════════════════════════════════════════════════════════════
   ALERTS
═══════════════════════════════════════════════════════════════ */
export function useStockAlerts() {
  return useQuery<StockAlert[]>({
    queryKey: tk('alerts'),
    queryFn:  () => api.get('/api/stock/alerts'),
    staleTime: 1000 * 60,
  })
}

/* ═══════════════════════════════════════════════════════════════
   INVOICE LINK (called by Factures page — optional integration)
═══════════════════════════════════════════════════════════════ */
export function useLinkProductToInvoiceLine() {
  return useMutation({
    mutationFn: (data: { facture_line_id: string; product_id: string; quantite: number }) =>
      api.post('/api/stock/invoice-links', data),
    /* Silent — used internally after facture creation */
  })
}
