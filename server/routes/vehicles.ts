import { Router, Request, Response } from 'express'
import { tenantQuery, tenantQueryOne } from '../db/pool'
import { requireAuth } from '../middleware/auth'

const router = Router()
router.use(requireAuth)

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

async function insertRow(
  tenantId: string,
  table: string,
  data: Record<string, unknown>,
) {
  const withTenant = { tenant_id: tenantId, ...data }
  const keys = Object.keys(withTenant).filter(k => SAFE_COL.test(k))
  const vals = keys.map(k => withTenant[k])
  const ph   = keys.map((_, i) => `$${i + 1}`).join(', ')
  return tenantQueryOne(
    tenantId,
    `INSERT INTO ${table} (${keys.join(', ')}) VALUES (${ph}) RETURNING *`,
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
   VEHICLES
═══════════════════════════════════════════════════════════════ */
const VEHICLE_FIELDS = [
  'immatriculation','marque','modele','type','annee','vin','carburant_type',
  'date_achat','prix_achat','kilometrage','conducteur_principal',
  'image_url','notes','statut',
] as const

router.get('/', async (req: Request, res: Response) => {
  try {
    const rows = await tenantQuery(req.user!.tenantId,
      `SELECT v.*,
              (SELECT COALESCE(SUM(prix_total), 0) FROM vehicle_fuel_logs f
                WHERE f.vehicle_id = v.id AND f.date >= date_trunc('month', CURRENT_DATE))
                AS fuel_month_cost,
              (SELECT COALESCE(SUM(montant), 0) FROM vehicle_maintenance m
                WHERE m.vehicle_id = v.id AND m.date >= date_trunc('month', CURRENT_DATE))
                AS maint_month_cost
       FROM service_vehicles v
       ORDER BY v.created_at DESC`,
    )
    res.json(rows)
  } catch (err: any) {
    console.error('[vehicles GET]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.get('/alerts', async (req: Request, res: Response) => {
  try {
    /* Documents expiring within 30 days OR already expired */
    const docs = await tenantQuery(req.user!.tenantId,
      `SELECT d.id, d.type, d.numero, d.emetteur, d.date_fin,
              v.id AS vehicle_id, v.marque, v.modele, v.immatriculation,
              (d.date_fin - CURRENT_DATE) AS days_left
       FROM vehicle_documents d
       JOIN service_vehicles v ON v.id = d.vehicle_id
       WHERE d.date_fin <= CURRENT_DATE + INTERVAL '30 days'
       ORDER BY d.date_fin ASC`,
    )
    /* Maintenance due (date or km) */
    const maint = await tenantQuery(req.user!.tenantId,
      `SELECT m.id, m.type, m.description, m.prochaine_date, m.prochaine_km,
              v.id AS vehicle_id, v.marque, v.modele, v.immatriculation, v.kilometrage,
              CASE
                WHEN m.prochaine_date IS NOT NULL THEN (m.prochaine_date - CURRENT_DATE)::int
                ELSE NULL
              END AS days_left,
              CASE
                WHEN m.prochaine_km IS NOT NULL THEN (m.prochaine_km - v.kilometrage)
                ELSE NULL
              END AS km_left
       FROM vehicle_maintenance m
       JOIN service_vehicles v ON v.id = m.vehicle_id
       WHERE (m.prochaine_date IS NOT NULL AND m.prochaine_date <= CURRENT_DATE + INTERVAL '30 days')
          OR (m.prochaine_km IS NOT NULL AND m.prochaine_km - v.kilometrage <= 1000)
       ORDER BY COALESCE(m.prochaine_date, CURRENT_DATE + INTERVAL '999 days') ASC`,
    )
    res.json({ documents: docs, maintenance: maint })
  } catch (err: any) {
    console.error('[vehicles/alerts]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.get('/:id', async (req: Request, res: Response) => {
  try {
    const v = await tenantQueryOne(req.user!.tenantId,
      `SELECT * FROM service_vehicles WHERE id = $1`, [req.params.id])
    if (!v) return res.status(404).json({ error: 'Non trouvé' })
    res.json(v)
  } catch (err: any) {
    console.error('[vehicles GET:id]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.get('/:id/stats', async (req: Request, res: Response) => {
  try {
    const stats = await tenantQueryOne(req.user!.tenantId,
      `WITH v AS (SELECT id, kilometrage, prix_achat FROM service_vehicles WHERE id = $1),
            f AS (SELECT
                    COALESCE(SUM(litres), 0)     AS total_litres,
                    COALESCE(SUM(prix_total), 0) AS total_fuel_cost,
                    COUNT(*)                     AS pleins,
                    COALESCE(MAX(kilometrage) - MIN(kilometrage), 0) AS km_range
                  FROM vehicle_fuel_logs WHERE vehicle_id = $1),
            m AS (SELECT COALESCE(SUM(montant), 0) AS total_maint_cost,
                         COUNT(*)                   AS interventions
                  FROM vehicle_maintenance WHERE vehicle_id = $1),
            t AS (SELECT COUNT(*) AS trips,
                         COALESCE(SUM(km_arrivee - km_depart), 0) AS km_trips
                  FROM vehicle_trips WHERE vehicle_id = $1)
       SELECT
         (SELECT kilometrage FROM v)             AS kilometrage,
         (SELECT prix_achat  FROM v)             AS prix_achat,
         f.total_litres, f.total_fuel_cost, f.pleins, f.km_range,
         m.total_maint_cost, m.interventions,
         t.trips, t.km_trips,
         CASE
           WHEN f.km_range > 0
           THEN ROUND((f.total_litres / f.km_range * 100)::numeric, 2)
           ELSE 0
         END AS conso_l_100km,
         CASE
           WHEN (SELECT kilometrage FROM v) > 0
           THEN ROUND(((f.total_fuel_cost + m.total_maint_cost) / (SELECT kilometrage FROM v))::numeric, 2)
           ELSE 0
         END AS cost_per_km
       FROM f, m, t`,
      [req.params.id])
    res.json(stats ?? {})
  } catch (err: any) {
    console.error('[vehicles/:id/stats]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.post('/', async (req: Request, res: Response) => {
  try {
    const data = pickFields(req.body, VEHICLE_FIELDS)
    if (!data.immatriculation) return res.status(400).json({ error: 'Immatriculation requise' })
    if (!data.marque || !data.modele) return res.status(400).json({ error: 'Marque + modèle requis' })
    const row = await insertRow(req.user!.tenantId, 'service_vehicles', data)
    res.status(201).json(row)
  } catch (err: any) {
    if (err.code === '23505') return res.status(409).json({ error: 'Immatriculation déjà utilisée' })
    console.error('[vehicles POST]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.patch('/:id', async (req: Request, res: Response) => {
  try {
    const row = await updateRow(req.user!.tenantId, 'service_vehicles', req.params.id,
      pickFields(req.body, VEHICLE_FIELDS))
    if (!row) return res.status(404).json({ error: 'Non trouvé' })
    res.json(row)
  } catch (err: any) {
    if (err.code === '23505') return res.status(409).json({ error: 'Immatriculation déjà utilisée' })
    console.error('[vehicles PATCH]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.delete('/:id', async (req: Request, res: Response) => {
  try {
    await tenantQuery(req.user!.tenantId,
      `DELETE FROM service_vehicles WHERE id = $1`, [req.params.id])
    res.json({ success: true })
  } catch (err: any) {
    console.error('[vehicles DELETE]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* ═══════════════════════════════════════════════════════════════
   FUEL LOGS
═══════════════════════════════════════════════════════════════ */
const FUEL_FIELDS = [
  'vehicle_id','date','kilometrage','litres','prix_total',
  'station','conducteur','is_full','notes',
] as const

router.get('/fuel/all', async (req: Request, res: Response) => {
  try {
    const rows = await tenantQuery(req.user!.tenantId,
      `SELECT f.*,
              v.immatriculation, v.marque, v.modele,
              CASE WHEN f.litres > 0 THEN ROUND((f.prix_total / f.litres)::numeric, 3) ELSE 0 END AS prix_litre
       FROM vehicle_fuel_logs f
       JOIN service_vehicles v ON v.id = f.vehicle_id
       ORDER BY f.date DESC LIMIT 500`,
    )
    res.json(rows)
  } catch (err: any) {
    console.error('[fuel/all]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.get('/:id/fuel', async (req: Request, res: Response) => {
  try {
    const rows = await tenantQuery(req.user!.tenantId,
      `SELECT *,
              CASE WHEN litres > 0 THEN ROUND((prix_total / litres)::numeric, 3) ELSE 0 END AS prix_litre
       FROM vehicle_fuel_logs WHERE vehicle_id = $1 ORDER BY date DESC`,
      [req.params.id],
    )
    res.json(rows)
  } catch (err: any) {
    console.error('[vehicles/:id/fuel]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.post('/:id/fuel', async (req: Request, res: Response) => {
  try {
    const data = pickFields({ ...req.body, vehicle_id: req.params.id }, FUEL_FIELDS) as Record<string, unknown>
    if (!data.kilometrage || !data.litres || data.prix_total == null) {
      return res.status(400).json({ error: 'kilometrage, litres et prix_total requis' })
    }
    const row = await insertRow(req.user!.tenantId, 'vehicle_fuel_logs', data)
    res.status(201).json(row)
  } catch (err: any) {
    console.error('[fuel POST]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.delete('/fuel/:id', async (req: Request, res: Response) => {
  try {
    await tenantQuery(req.user!.tenantId,
      `DELETE FROM vehicle_fuel_logs WHERE id = $1`, [req.params.id])
    res.json({ success: true })
  } catch (err: any) {
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* ═══════════════════════════════════════════════════════════════
   MAINTENANCE
═══════════════════════════════════════════════════════════════ */
const MAINT_FIELDS = [
  'vehicle_id','date','type','description','garage','kilometrage',
  'montant','prochaine_date','prochaine_km','notes',
] as const

router.get('/maintenance/all', async (req: Request, res: Response) => {
  try {
    const rows = await tenantQuery(req.user!.tenantId,
      `SELECT m.*, v.immatriculation, v.marque, v.modele
       FROM vehicle_maintenance m
       JOIN service_vehicles v ON v.id = m.vehicle_id
       ORDER BY m.date DESC LIMIT 500`,
    )
    res.json(rows)
  } catch (err: any) {
    console.error('[maintenance/all]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.get('/:id/maintenance', async (req: Request, res: Response) => {
  try {
    const rows = await tenantQuery(req.user!.tenantId,
      `SELECT * FROM vehicle_maintenance WHERE vehicle_id = $1 ORDER BY date DESC`,
      [req.params.id])
    res.json(rows)
  } catch (err: any) {
    console.error('[vehicles/:id/maintenance]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.post('/:id/maintenance', async (req: Request, res: Response) => {
  try {
    const data = pickFields({ ...req.body, vehicle_id: req.params.id }, MAINT_FIELDS) as Record<string, unknown>
    if (!data.description) return res.status(400).json({ error: 'Description requise' })
    const row = await insertRow(req.user!.tenantId, 'vehicle_maintenance', data)
    res.status(201).json(row)
  } catch (err: any) {
    console.error('[maintenance POST]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.patch('/maintenance/:id', async (req: Request, res: Response) => {
  try {
    const row = await updateRow(req.user!.tenantId, 'vehicle_maintenance', req.params.id,
      pickFields(req.body, MAINT_FIELDS))
    if (!row) return res.status(404).json({ error: 'Non trouvé' })
    res.json(row)
  } catch (err: any) {
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.delete('/maintenance/:id', async (req: Request, res: Response) => {
  try {
    await tenantQuery(req.user!.tenantId,
      `DELETE FROM vehicle_maintenance WHERE id = $1`, [req.params.id])
    res.json({ success: true })
  } catch (err: any) {
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* ═══════════════════════════════════════════════════════════════
   DOCUMENTS
═══════════════════════════════════════════════════════════════ */
const DOC_FIELDS = [
  'vehicle_id','type','numero','emetteur','date_debut','date_fin','montant','notes',
] as const

router.get('/documents/all', async (req: Request, res: Response) => {
  try {
    const rows = await tenantQuery(req.user!.tenantId,
      `SELECT d.*, v.immatriculation, v.marque, v.modele,
              (d.date_fin - CURRENT_DATE) AS days_left
       FROM vehicle_documents d
       JOIN service_vehicles v ON v.id = d.vehicle_id
       ORDER BY d.date_fin ASC LIMIT 500`,
    )
    res.json(rows)
  } catch (err: any) {
    console.error('[documents/all]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.get('/:id/documents', async (req: Request, res: Response) => {
  try {
    const rows = await tenantQuery(req.user!.tenantId,
      `SELECT *, (date_fin - CURRENT_DATE) AS days_left
       FROM vehicle_documents WHERE vehicle_id = $1 ORDER BY date_fin ASC`,
      [req.params.id])
    res.json(rows)
  } catch (err: any) {
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.post('/:id/documents', async (req: Request, res: Response) => {
  try {
    const data = pickFields({ ...req.body, vehicle_id: req.params.id }, DOC_FIELDS) as Record<string, unknown>
    if (!data.type || !data.date_fin) return res.status(400).json({ error: 'Type et date_fin requis' })
    const row = await insertRow(req.user!.tenantId, 'vehicle_documents', data)
    res.status(201).json(row)
  } catch (err: any) {
    console.error('[documents POST]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.patch('/documents/:id', async (req: Request, res: Response) => {
  try {
    const row = await updateRow(req.user!.tenantId, 'vehicle_documents', req.params.id,
      pickFields(req.body, DOC_FIELDS))
    if (!row) return res.status(404).json({ error: 'Non trouvé' })
    res.json(row)
  } catch (err: any) {
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.delete('/documents/:id', async (req: Request, res: Response) => {
  try {
    await tenantQuery(req.user!.tenantId,
      `DELETE FROM vehicle_documents WHERE id = $1`, [req.params.id])
    res.json({ success: true })
  } catch (err: any) {
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* ═══════════════════════════════════════════════════════════════
   TRIPS
═══════════════════════════════════════════════════════════════ */
const TRIP_FIELDS = [
  'vehicle_id','client_id','client_nom','date','conducteur',
  'km_depart','km_arrivee','motif','notes',
] as const

router.get('/:id/trips', async (req: Request, res: Response) => {
  try {
    const rows = await tenantQuery(req.user!.tenantId,
      `SELECT * FROM vehicle_trips WHERE vehicle_id = $1 ORDER BY date DESC`,
      [req.params.id])
    res.json(rows)
  } catch (err: any) {
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

router.post('/:id/trips', async (req: Request, res: Response) => {
  try {
    const data = pickFields({ ...req.body, vehicle_id: req.params.id }, TRIP_FIELDS) as Record<string, unknown>
    if (data.km_depart == null || data.km_arrivee == null) {
      return res.status(400).json({ error: 'km_depart et km_arrivee requis' })
    }
    const row = await insertRow(req.user!.tenantId, 'vehicle_trips', data)
    res.status(201).json(row)
  } catch (err: any) {
    console.error('[trips POST]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* ═══════════════════════════════════════════════════════════════
   GPS POSITIONS
═══════════════════════════════════════════════════════════════ */
const POSITION_FIELDS = [
  'recorded_at','lat','lng','accuracy','speed','heading','altitude','source','driver',
] as const

/* Push a new position from the driver's browser. Coords validated in DB. */
router.post('/:id/positions', async (req: Request, res: Response) => {
  try {
    const lat = Number(req.body?.lat)
    const lng = Number(req.body?.lng)
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
      return res.status(400).json({ error: 'lat/lng invalides' })
    }
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return res.status(400).json({ error: 'lat/lng hors plage' })
    }
    const data = pickFields(
      { ...req.body, lat, lng, vehicle_id: req.params.id },
      [...POSITION_FIELDS, 'vehicle_id'],
    )
    const row = await insertRow(req.user!.tenantId, 'vehicle_positions', data)
    res.status(201).json(row)
  } catch (err: any) {
    console.error('[positions POST]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* Latest known position for every vehicle in this tenant (for fleet map). */
router.get('/positions/latest', async (req: Request, res: Response) => {
  try {
    const rows = await tenantQuery(req.user!.tenantId,
      `SELECT DISTINCT ON (p.vehicle_id)
              p.vehicle_id, p.lat, p.lng, p.recorded_at, p.speed, p.heading, p.accuracy, p.driver,
              v.marque, v.modele, v.immatriculation, v.statut, v.type, v.image_url,
              EXTRACT(EPOCH FROM (now() - p.recorded_at))::int AS seconds_ago
       FROM vehicle_positions p
       JOIN service_vehicles  v ON v.id = p.vehicle_id
       ORDER BY p.vehicle_id, p.recorded_at DESC`,
    )
    res.json(rows)
  } catch (err: any) {
    console.error('[positions/latest]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* History for one vehicle — useful for trail rendering on the map. */
router.get('/:id/positions', async (req: Request, res: Response) => {
  const limit = Math.min(Number(req.query.limit) || 200, 1000)
  const since = String(req.query.since || '')
  try {
    const params: any[] = [req.params.id]
    let where = 'vehicle_id = $1'
    if (since) {
      params.push(since)
      where += ` AND recorded_at >= $${params.length}`
    }
    params.push(limit)
    const rows = await tenantQuery(req.user!.tenantId,
      `SELECT id, recorded_at, lat, lng, speed, heading, accuracy, source
       FROM vehicle_positions
       WHERE ${where}
       ORDER BY recorded_at DESC
       LIMIT $${params.length}`,
      params,
    )
    res.json(rows)
  } catch (err: any) {
    console.error('[:id/positions]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

export default router
