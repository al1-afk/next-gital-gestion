import { Router } from 'express'
import { query, queryOne } from '../db/pool'
import { requireAuth } from '../middleware/auth'

const router = Router()

/* ── GET /api/tenants/resolve/:slug — public (no auth) ──────── */
router.get('/resolve/:slug', async (req, res) => {
  const { slug } = req.params
  const tenant = await queryOne(
    `SELECT id, slug, name, plan, logo_url, primary_color, is_active
     FROM tenants WHERE slug = $1 AND is_active = TRUE`,
    [slug.toLowerCase()]
  )
  if (!tenant) return res.status(404).json({ error: 'Workspace introuvable' })
  res.json(tenant)
})

/* ── GET /api/tenants/members — liste membres du tenant ──────── */
router.get('/members', requireAuth, async (req, res) => {
  const { tenantId } = req.user!
  const members = await query(
    `SELECT tu.id, tu.role, tu.status, tu.invited_at, tu.accepted_at,
            u.email, u.name
     FROM tenant_users tu
     LEFT JOIN users u ON u.id = tu.user_id
     WHERE tu.tenant_id = $1
     ORDER BY tu.invited_at DESC`,
    [tenantId]
  )
  res.json(members)
})

/* ── PATCH /api/tenants — mettre à jour le tenant (admin) ───── */
router.patch('/', requireAuth, async (req, res) => {
  if (req.user!.role !== 'admin') return res.status(403).json({ error: 'Admin requis' })
  const { name, logo_url, primary_color, settings } = req.body
  const tenant = await queryOne(
    `UPDATE tenants SET name = COALESCE($1, name),
      logo_url = COALESCE($2, logo_url),
      primary_color = COALESCE($3, primary_color),
      settings = COALESCE($4, settings),
      updated_at = NOW()
     WHERE id = $5 RETURNING *`,
    [name, logo_url, primary_color, settings, req.user!.tenantId]
  )
  res.json(tenant)
})

/* ── POST /api/tenants/invite ────────────────────────────────── */
router.post('/invite', requireAuth, async (req, res) => {
  if (!['admin', 'manager'].includes(req.user!.role)) {
    return res.status(403).json({ error: 'Permission insuffisante' })
  }
  const { email, role = 'viewer' } = req.body
  const { tenantId, userId } = req.user!

  const invitee = await queryOne<{ id: string }>(
    `SELECT id FROM users WHERE email = $1`, [email]
  )

  const member = await queryOne(
    `INSERT INTO tenant_users (tenant_id, user_id, role, invited_by, status)
     VALUES ($1, $2, $3, $4, $5)
     ON CONFLICT (tenant_id, user_id) DO UPDATE SET role = EXCLUDED.role, status = 'active'
     RETURNING *`,
    [tenantId, invitee?.id ?? null, role, userId, invitee ? 'active' : 'pending']
  )
  res.status(201).json(member)
})

/* ── DELETE /api/tenants/members/:memberId ───────────────────── */
router.delete('/members/:memberId', requireAuth, async (req, res) => {
  if (req.user!.role !== 'admin') return res.status(403).json({ error: 'Admin requis' })
  await query(
    `UPDATE tenant_users SET status = 'revoked'
     WHERE id = $1 AND tenant_id = $2`,
    [req.params.memberId, req.user!.tenantId]
  )
  res.json({ success: true })
})

export default router
