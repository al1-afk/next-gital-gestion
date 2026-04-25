import { Router, Request, Response } from 'express'
import { tenantQuery, tenantQueryOne } from '../db/pool'
import { requireAuth } from '../middleware/auth'

const router = Router()
router.use(requireAuth)

/* ── Helpers ─────────────────────────────────────────────────── */

const SAFE_COL = /^[a-z_][a-z0-9_]{0,63}$/

function pickFields<T extends Record<string, unknown>>(
  body: T,
  allowed: readonly string[],
): Record<string, unknown> {
  const out: Record<string, unknown> = {}
  for (const k of allowed) {
    if (k in body) {
      const v = (body as Record<string, unknown>)[k]
      out[k] = v === '' ? null : v
    }
  }
  return out
}

function generateSku(): string {
  const ts   = Date.now().toString(36).toUpperCase()
  const rand = Math.random().toString(36).slice(2, 6).toUpperCase()
  return `PRD-${ts}-${rand}`
}

async function insertRow(
  tenantId: string,
  table: string,
  data: Record<string, unknown>,
) {
  const withTenant = { tenant_id: tenantId, ...data }
  const keys = Object.keys(withTenant).filter(k => SAFE_COL.test(k))
  const vals = keys.map(k => withTenant[k])
  const ph   = keys.map((_, i) => `$${i + 1}`).join(', ')
  const cols = keys.join(', ')
  return tenantQueryOne(
    tenantId,
    `INSERT INTO ${table} (${cols}) VALUES (${ph}) RETURNING *`,
    vals,
  )
}

async function updateRow(
  tenantId: string,
  table: string,
  id: string,
  data: Record<string, unknown>,
) {
  const keys = Object.keys(data).filter(k => SAFE_COL.test(k) && k !== 'tenant_id' && k !== 'id')
  if (!keys.length) {
    return tenantQueryOne(tenantId, `SELECT * FROM ${table} WHERE id = $1`, [id])
  }
  const sets = keys.map((k, i) => `${k} = $${i + 2}`).join(', ')
  const vals = keys.map(k => data[k])
  return tenantQueryOne(
    tenantId,
    `UPDATE ${table} SET ${sets} WHERE id = $1 RETURNING *`,
    [id, ...vals],
  )
}

/* ═══════════════════════════════════════════════════════════════
   CATEGORIES
═══════════════════════════════════════════════════════════════ */

const CATEGORY_FIELDS = ['nom', 'description', 'color'] as const

router.get('/categories', async (req: Request, res: Response) => {
  try {
    const rows = await tenantQuery(
      req.user!.tenantId,
      `SELECT * FROM stock_categories ORDER BY nom ASC`,
    )
    res.json(rows)
  } catch (err: any) {
    console.error('[stock/categories GET]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.post('/categories', async (req: Request, res: Response) => {
  try {
    const data = pickFields(req.body, CATEGORY_FIELDS)
    if (!data.nom) return res.status(400).json({ error: 'Nom requis' })
    const row = await insertRow(req.user!.tenantId, 'stock_categories', data)
    res.status(201).json(row)
  } catch (err: any) {
    if (err.code === '23505') return res.status(409).json({ error: 'Catégorie déjà existante' })
    console.error('[stock/categories POST]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.patch('/categories/:id', async (req: Request, res: Response) => {
  try {
    const row = await updateRow(req.user!.tenantId, 'stock_categories', req.params.id,
      pickFields(req.body, CATEGORY_FIELDS))
    if (!row) return res.status(404).json({ error: 'Non trouvé' })
    res.json(row)
  } catch (err: any) {
    console.error('[stock/categories PATCH]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.delete('/categories/:id', async (req: Request, res: Response) => {
  try {
    await tenantQuery(req.user!.tenantId,
      `DELETE FROM stock_categories WHERE id = $1`, [req.params.id])
    res.json({ success: true })
  } catch (err: any) {
    console.error('[stock/categories DELETE]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* ═══════════════════════════════════════════════════════════════
   SUPPLIERS
═══════════════════════════════════════════════════════════════ */

const SUPPLIER_FIELDS = ['nom', 'email', 'telephone', 'adresse', 'notes'] as const

router.get('/suppliers', async (req: Request, res: Response) => {
  try {
    const rows = await tenantQuery(req.user!.tenantId,
      `SELECT * FROM stock_suppliers ORDER BY nom ASC`)
    res.json(rows)
  } catch (err: any) {
    console.error('[stock/suppliers GET]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.post('/suppliers', async (req: Request, res: Response) => {
  try {
    const data = pickFields(req.body, SUPPLIER_FIELDS)
    if (!data.nom) return res.status(400).json({ error: 'Nom requis' })
    const row = await insertRow(req.user!.tenantId, 'stock_suppliers', data)
    res.status(201).json(row)
  } catch (err: any) {
    console.error('[stock/suppliers POST]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.patch('/suppliers/:id', async (req: Request, res: Response) => {
  try {
    const row = await updateRow(req.user!.tenantId, 'stock_suppliers', req.params.id,
      pickFields(req.body, SUPPLIER_FIELDS))
    if (!row) return res.status(404).json({ error: 'Non trouvé' })
    res.json(row)
  } catch (err: any) {
    console.error('[stock/suppliers PATCH]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.delete('/suppliers/:id', async (req: Request, res: Response) => {
  try {
    await tenantQuery(req.user!.tenantId,
      `DELETE FROM stock_suppliers WHERE id = $1`, [req.params.id])
    res.json({ success: true })
  } catch (err: any) {
    console.error('[stock/suppliers DELETE]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* ═══════════════════════════════════════════════════════════════
   PRODUCTS
═══════════════════════════════════════════════════════════════ */

const PRODUCT_FIELDS = [
  'sku', 'nom', 'description', 'category_id', 'supplier_id',
  'prix_achat', 'prix_vente', 'tva',
  'stock_actuel', 'stock_minimum',
  'image_url', 'is_active',
] as const

router.get('/products', async (req: Request, res: Response) => {
  const limit  = Math.min(Number(req.query.limit)  || 200, 1000)
  const offset = Math.max(Number(req.query.offset) || 0, 0)
  const search = String(req.query.search || '').trim()

  try {
    const where:  string[] = []
    const params: any[]    = []

    if (search) {
      params.push(`%${search.toLowerCase()}%`)
      where.push(`(LOWER(p.nom) LIKE $${params.length} OR LOWER(p.sku) LIKE $${params.length})`)
    }
    const whereSQL = where.length ? `WHERE ${where.join(' AND ')}` : ''

    params.push(limit)
    params.push(offset)

    const rows = await tenantQuery(req.user!.tenantId,
      `SELECT p.*,
              c.nom   AS category_nom,
              c.color AS category_color,
              s.nom   AS supplier_nom
       FROM stock_products p
       LEFT JOIN stock_categories c ON c.id = p.category_id
       LEFT JOIN stock_suppliers  s ON s.id = p.supplier_id
       ${whereSQL}
       ORDER BY p.created_at DESC
       LIMIT $${params.length - 1} OFFSET $${params.length}`,
      params,
    )
    res.json(rows)
  } catch (err: any) {
    console.error('[stock/products GET]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.get('/products/:id', async (req: Request, res: Response) => {
  try {
    const row = await tenantQueryOne(req.user!.tenantId,
      `SELECT * FROM stock_products WHERE id = $1`, [req.params.id])
    if (!row) return res.status(404).json({ error: 'Non trouvé' })
    res.json(row)
  } catch (err: any) {
    console.error('[stock/products GET:id]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.post('/products', async (req: Request, res: Response) => {
  try {
    const data = pickFields(req.body, PRODUCT_FIELDS) as Record<string, unknown>
    if (!data.nom) return res.status(400).json({ error: 'Nom requis' })
    if (!data.sku || String(data.sku).trim() === '') data.sku = generateSku()

    const row = await insertRow(req.user!.tenantId, 'stock_products', data)
    res.status(201).json(row)
  } catch (err: any) {
    if (err.code === '23505') return res.status(409).json({ error: 'SKU déjà utilisé' })
    console.error('[stock/products POST]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.patch('/products/:id', async (req: Request, res: Response) => {
  try {
    const data = pickFields(req.body, PRODUCT_FIELDS)
    const row = await updateRow(req.user!.tenantId, 'stock_products', req.params.id, data)
    if (!row) return res.status(404).json({ error: 'Non trouvé' })
    res.json(row)
  } catch (err: any) {
    if (err.code === '23505') return res.status(409).json({ error: 'SKU déjà utilisé' })
    console.error('[stock/products PATCH]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.delete('/products/:id', async (req: Request, res: Response) => {
  try {
    await tenantQuery(req.user!.tenantId,
      `DELETE FROM stock_products WHERE id = $1`, [req.params.id])
    res.json({ success: true })
  } catch (err: any) {
    console.error('[stock/products DELETE]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* ═══════════════════════════════════════════════════════════════
   MOVEMENTS  (trigger updates stock_actuel)
═══════════════════════════════════════════════════════════════ */

const MOVEMENT_FIELDS = [
  'product_id', 'type', 'quantite', 'reference', 'note', 'source', 'source_id',
] as const

router.get('/movements', async (req: Request, res: Response) => {
  const limit  = Math.min(Number(req.query.limit)  || 200, 1000)
  const offset = Math.max(Number(req.query.offset) || 0, 0)
  const productId = String(req.query.product_id || '')

  try {
    const where:  string[] = []
    const params: any[]    = []
    if (productId) {
      params.push(productId)
      where.push(`m.product_id = $${params.length}`)
    }
    const whereSQL = where.length ? `WHERE ${where.join(' AND ')}` : ''

    params.push(limit)
    params.push(offset)

    const rows = await tenantQuery(req.user!.tenantId,
      `SELECT m.*, p.nom AS product_nom, p.sku AS product_sku
       FROM stock_movements m
       LEFT JOIN stock_products p ON p.id = m.product_id
       ${whereSQL}
       ORDER BY m.created_at DESC
       LIMIT $${params.length - 1} OFFSET $${params.length}`,
      params,
    )
    res.json(rows)
  } catch (err: any) {
    console.error('[stock/movements GET]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.post('/movements', async (req: Request, res: Response) => {
  try {
    const data = pickFields(req.body, MOVEMENT_FIELDS) as Record<string, unknown>
    if (!data.product_id) return res.status(400).json({ error: 'Produit requis' })
    if (!data.type)       return res.status(400).json({ error: 'Type requis' })
    const qty = Number(data.quantite ?? 0)
    if (!Number.isFinite(qty) || qty < 0) {
      return res.status(400).json({ error: 'Quantité invalide' })
    }
    data.quantite = qty

    const row = await insertRow(req.user!.tenantId, 'stock_movements', data)
    res.status(201).json(row)
  } catch (err: any) {
    console.error('[stock/movements POST]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* ═══════════════════════════════════════════════════════════════
   ALERTS  — products below or at their minimum stock level
═══════════════════════════════════════════════════════════════ */

router.get('/alerts', async (req: Request, res: Response) => {
  try {
    const rows = await tenantQuery(req.user!.tenantId,
      `SELECT id, sku, nom, stock_actuel, stock_minimum,
              CASE WHEN stock_actuel <= 0 THEN 'rupture' ELSE 'faible' END AS level
       FROM stock_products
       WHERE is_active = true AND stock_actuel <= stock_minimum
       ORDER BY stock_actuel ASC, nom ASC`,
    )
    res.json(rows)
  } catch (err: any) {
    console.error('[stock/alerts GET]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* ═══════════════════════════════════════════════════════════════
   INVOICE LINKS  (optional, keeps facture_lines untouched)
═══════════════════════════════════════════════════════════════ */

router.post('/invoice-links', async (req: Request, res: Response) => {
  const { facture_line_id, product_id, quantite } = req.body || {}
  if (!facture_line_id || !product_id) {
    return res.status(400).json({ error: 'facture_line_id et product_id requis' })
  }
  const qty = Number(quantite ?? 1)
  if (!Number.isFinite(qty) || qty <= 0) {
    return res.status(400).json({ error: 'Quantité invalide' })
  }
  try {
    const row = await tenantQueryOne(req.user!.tenantId,
      `INSERT INTO stock_invoice_links (tenant_id, facture_line_id, product_id, quantite)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (facture_line_id) DO UPDATE
         SET product_id = EXCLUDED.product_id,
             quantite   = EXCLUDED.quantite
       RETURNING *`,
      [req.user!.tenantId, facture_line_id, product_id, qty],
    )
    res.status(201).json(row)
  } catch (err: any) {
    console.error('[stock/invoice-links POST]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

export default router
