/**
 * Member-only endpoints. Requires JWT with role === 'team_member'.
 *
 *  GET    /api/my-space/dashboard         — stats overview
 *  GET    /api/my-space/profile           — full profile
 *  PUT    /api/my-space/profile           — update phone/avatar
 *  PUT    /api/my-space/password          — change password
 *  GET    /api/my-space/tasks             — my tasks
 *  PATCH  /api/my-space/tasks/:id         — update status
 *  GET    /api/my-space/sops              — SOPs filtered by my access
 *  GET    /api/my-space/sops/:id          — single SOP (if I have access)
 *  POST   /api/my-space/sops/activity     — log a SOP-viewed action
 */
import { Router, Request, Response, NextFunction } from 'express'
import bcrypt from 'bcryptjs'
import { query, queryOne, tenantQuery, tenantQueryOne } from '../db/pool'
import { requireAuth } from '../middleware/auth'

const router = Router()
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

/* All routes require a team_member JWT */
router.use(requireAuth)
router.use((req: Request, res: Response, next: NextFunction) => {
  if (req.user?.role !== 'team_member') {
    return res.status(403).json({ error: 'Espace réservé aux membres' })
  }
  next()
})

/* Resolve the team_member row for the current user (cached per-request via res.locals) */
async function resolveMember(req: Request): Promise<{ id: string; tenantId: string } | null> {
  if ((req as any)._memberCache) return (req as any)._memberCache
  const row = await queryOne<{ id: string; tenant_id: string; account_status: string }>(
    `SELECT id, tenant_id, account_status
       FROM public.team_members
      WHERE user_id = $1 AND tenant_id = $2 LIMIT 1`,
    [req.user!.userId, req.user!.tenantId],
  )
  if (!row || row.account_status !== 'active') return null
  const cached = { id: row.id, tenantId: row.tenant_id }
  ;(req as any)._memberCache = cached
  return cached
}

async function logActivity(
  tenantId: string,
  teamMemberId: string,
  actionType: string,
  details: Record<string, unknown> = {},
  ip?: string,
  ua?: string,
) {
  try {
    await tenantQuery(
      tenantId,
      `INSERT INTO public.team_member_activity (tenant_id, team_member_id, action_type, action_details, ip_address, user_agent)
       VALUES ($1, $2, $3, $4::jsonb, $5::inet, $6)`,
      [tenantId, teamMemberId, actionType, JSON.stringify(details), ip ?? null, ua ?? null],
    )
  } catch (e: any) { console.error('[my-space:activity]', e.message) }
}

/* ────────────────────────────────────────────────────────────────── */

/* GET /api/my-space/profile */
router.get('/profile', async (req: Request, res: Response) => {
  const m = await resolveMember(req)
  if (!m) return res.status(403).json({ error: 'Compte inactif' })

  try {
    const profile = await tenantQueryOne(
      m.tenantId,
      `SELECT m.id, m.prenom AS first_name, m.nom AS last_name, m.email, m.telephone,
              m.job_title, m.member_type, m.avatar_url, m.last_login_at, m.created_at,
              m.invitation_accepted_at,
              COALESCE(
                (SELECT json_agg(json_build_object('category', sop_category, 'level', access_level))
                   FROM public.team_member_sop_access WHERE team_member_id = m.id), '[]'::json
              ) AS access
         FROM public.team_members m WHERE m.id = $1`,
      [m.id],
    )
    res.json(profile)
  } catch (err: any) {
    console.error('[my-space:profile]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* PUT /api/my-space/profile — limited fields the member can edit */
router.put('/profile', async (req: Request, res: Response) => {
  const m = await resolveMember(req)
  if (!m) return res.status(403).json({ error: 'Compte inactif' })

  const allowed = ['telephone','avatar_url']
  const data: Record<string, any> = {}
  for (const k of allowed) if (req.body[k] !== undefined) data[k] = req.body[k]
  if (!Object.keys(data).length) return res.status(400).json({ error: 'Aucun champ à mettre à jour' })

  const keys = Object.keys(data)
  const sets = keys.map((k, i) => `${k} = $${i + 1}`).join(', ')
  try {
    await tenantQuery(
      m.tenantId,
      `UPDATE public.team_members SET ${sets}, updated_at = NOW() WHERE id = $${keys.length + 1}`,
      [...keys.map(k => data[k]), m.id],
    )
    res.json({ success: true })
  } catch (err: any) {
    console.error('[my-space:profile-put]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* PUT /api/my-space/password */
router.put('/password', async (req: Request, res: Response) => {
  const m = await resolveMember(req)
  if (!m) return res.status(403).json({ error: 'Compte inactif' })

  const { current_password, new_password } = req.body
  if (!current_password || !new_password) {
    return res.status(400).json({ error: 'Ancien et nouveau mot de passe requis' })
  }
  if (new_password.length < 8) return res.status(400).json({ error: 'Nouveau mot de passe : minimum 8 caractères' })
  if (!/[0-9]/.test(new_password)) return res.status(400).json({ error: 'Doit contenir au moins un chiffre' })

  try {
    const user = await queryOne<{ password_hash: string }>(
      `SELECT password_hash FROM public.users WHERE id = $1`, [req.user!.userId],
    )
    if (!user) return res.status(404).json({ error: 'Compte introuvable' })

    const ok = await bcrypt.compare(current_password, user.password_hash)
    if (!ok) return res.status(401).json({ error: 'Ancien mot de passe incorrect' })

    const hash = await bcrypt.hash(new_password, 12)
    await query(`UPDATE public.users SET password_hash = $1, updated_at = NOW() WHERE id = $2`, [hash, req.user!.userId])
    await logActivity(m.tenantId, m.id, 'password_changed', {}, req.ip, req.headers['user-agent'] as string)
    res.json({ success: true })
  } catch (err: any) {
    console.error('[my-space:password]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* GET /api/my-space/dashboard */
router.get('/dashboard', async (req: Request, res: Response) => {
  const m = await resolveMember(req)
  if (!m) return res.status(403).json({ error: 'Compte inactif' })

  try {
    const [profile, accessRows, taskStats, recentActivity, sopCounts] = await Promise.all([
      tenantQueryOne<{ first_name: string; last_name: string; job_title: string | null; last_login_at: string | null }>(
        m.tenantId,
        `SELECT prenom AS first_name, nom AS last_name, job_title, last_login_at
           FROM public.team_members WHERE id = $1`, [m.id],
      ),
      tenantQuery<{ sop_category: string; access_level: string }>(
        m.tenantId,
        `SELECT sop_category, access_level FROM public.team_member_sop_access WHERE team_member_id = $1`, [m.id],
      ),
      tenantQueryOne<{ total: number; done: number; in_progress: number; todo: number; overdue: number }>(
        m.tenantId,
        `SELECT COUNT(*)::int AS total,
                COUNT(*) FILTER (WHERE status = 'done')::int        AS done,
                COUNT(*) FILTER (WHERE status = 'in_progress')::int AS in_progress,
                COUNT(*) FILTER (WHERE status = 'todo')::int        AS todo,
                COUNT(*) FILTER (WHERE status IN ('todo','in_progress') AND due_date < CURRENT_DATE)::int AS overdue
           FROM public.team_member_tasks WHERE team_member_id = $1`, [m.id],
      ),
      tenantQuery(
        m.tenantId,
        `SELECT action_type, action_details, created_at
           FROM public.team_member_activity WHERE team_member_id = $1
           ORDER BY created_at DESC LIMIT 10`, [m.id],
      ),
      tenantQuery<{ category: string; count: number }>(
        m.tenantId,
        `SELECT category, COUNT(*)::int AS count FROM public.sops GROUP BY category`,
      ),
    ])

    const sopCountByCat: Record<string, number> = {}
    for (const r of sopCounts) sopCountByCat[r.category] = r.count

    res.json({
      profile,
      access: accessRows.map(r => ({
        category: r.sop_category,
        level:    r.access_level,
        total_sops: sopCountByCat[r.sop_category] ?? 0,
      })),
      tasks: taskStats,
      recent_activity: recentActivity,
    })
  } catch (err: any) {
    console.error('[my-space:dashboard]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* GET /api/my-space/tasks */
router.get('/tasks', async (req: Request, res: Response) => {
  const m = await resolveMember(req)
  if (!m) return res.status(403).json({ error: 'Compte inactif' })
  try {
    const tasks = await tenantQuery(
      m.tenantId,
      `SELECT id, title, description, priority, status, due_date, created_at, completed_at
         FROM public.team_member_tasks WHERE team_member_id = $1
         ORDER BY (status = 'done'), due_date NULLS LAST, created_at DESC`,
      [m.id],
    )
    res.json(tasks)
  } catch (err: any) { res.status(500).json({ error: 'Erreur serveur' }) }
})

/* PATCH /api/my-space/tasks/:id — member can only update status */
router.patch('/tasks/:id', async (req: Request, res: Response) => {
  const m = await resolveMember(req)
  if (!m) return res.status(403).json({ error: 'Compte inactif' })

  const { id } = req.params
  if (!UUID_RE.test(id)) return res.status(400).json({ error: 'ID invalide' })

  const status = req.body.status
  if (!['todo','in_progress','done'].includes(status)) {
    return res.status(400).json({ error: 'Statut invalide' })
  }

  try {
    const row = await tenantQueryOne(
      m.tenantId,
      `UPDATE public.team_member_tasks
          SET status = $1, updated_at = NOW(),
              completed_at = CASE WHEN $1 = 'done' THEN NOW() ELSE NULL END
        WHERE id = $2 AND team_member_id = $3 RETURNING id, title`,
      [status, id, m.id],
    )
    if (!row) return res.status(404).json({ error: 'Tâche introuvable' })
    await logActivity(
      m.tenantId, m.id,
      status === 'done' ? 'task_completed' : 'task_updated',
      { taskId: id, title: (row as any).title, status },
    )
    res.json({ success: true })
  } catch (err: any) {
    console.error('[my-space:task-patch]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* GET /api/my-space/sops — strictly filtered by access list */
router.get('/sops', async (req: Request, res: Response) => {
  const m = await resolveMember(req)
  if (!m) return res.status(403).json({ error: 'Compte inactif' })

  try {
    const access = await tenantQuery<{ sop_category: string }>(
      m.tenantId,
      `SELECT sop_category FROM public.team_member_sop_access WHERE team_member_id = $1`, [m.id],
    )
    const categories = access.map(a => a.sop_category)
    if (!categories.length) return res.json([])

    const filterByCat = typeof req.query.category === 'string' ? req.query.category : null
    if (filterByCat && !categories.includes(filterByCat)) {
      return res.status(403).json({ error: 'Catégorie non autorisée' })
    }

    const cats = filterByCat ? [filterByCat] : categories
    const sops = await tenantQuery(
      m.tenantId,
      `SELECT id, slug, title, description, category, tags, author, author_bg, read_min,
              views, popular, blocks, created_at, updated_at
         FROM public.sops WHERE category = ANY($1::text[])
         ORDER BY popular DESC, created_at DESC`,
      [cats],
    )
    res.json(sops)
  } catch (err: any) {
    console.error('[my-space:sops]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* GET /api/my-space/sops/:id — single SOP (must be in member's accessible category) */
router.get('/sops/:id', async (req: Request, res: Response) => {
  const m = await resolveMember(req)
  if (!m) return res.status(403).json({ error: 'Compte inactif' })

  const { id } = req.params
  if (!UUID_RE.test(id)) return res.status(400).json({ error: 'ID invalide' })

  try {
    const sop = await tenantQueryOne<{ category: string }>(
      m.tenantId,
      `SELECT * FROM public.sops WHERE id = $1`, [id],
    )
    if (!sop) return res.status(404).json({ error: 'SOP introuvable' })

    const allowed = await tenantQueryOne(
      m.tenantId,
      `SELECT 1 FROM public.team_member_sop_access
        WHERE team_member_id = $1 AND sop_category = $2 LIMIT 1`,
      [m.id, sop.category],
    )
    if (!allowed) return res.status(403).json({ error: 'Accès non autorisé à cette SOP' })

    /* Increment views (best-effort) */
    tenantQuery(m.tenantId, `UPDATE public.sops SET views = views + 1 WHERE id = $1`, [id]).catch(() => {})

    res.json(sop)
  } catch (err: any) {
    console.error('[my-space:sop-get]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* POST /api/my-space/sops/activity — log a sop_viewed or checklist event */
router.post('/sops/activity', async (req: Request, res: Response) => {
  const m = await resolveMember(req)
  if (!m) return res.status(403).json({ error: 'Compte inactif' })

  const { sop_id, action_type, details } = req.body
  if (!sop_id || !UUID_RE.test(sop_id)) return res.status(400).json({ error: 'sop_id invalide' })
  const validTypes = new Set(['sop_viewed','sop_checklist_completed','sop_marked_read','sop_note_added'])
  if (!validTypes.has(action_type)) return res.status(400).json({ error: 'action_type invalide' })

  try {
    /* Verify member has access to this SOP's category */
    const sop = await tenantQueryOne<{ category: string; title: string }>(
      m.tenantId,
      `SELECT category, title FROM public.sops WHERE id = $1`, [sop_id],
    )
    if (!sop) return res.status(404).json({ error: 'SOP introuvable' })
    const ok = await tenantQueryOne(
      m.tenantId,
      `SELECT 1 FROM public.team_member_sop_access WHERE team_member_id = $1 AND sop_category = $2 LIMIT 1`,
      [m.id, sop.category],
    )
    if (!ok) return res.status(403).json({ error: 'Accès non autorisé' })

    await logActivity(
      m.tenantId, m.id, action_type,
      { sop_id, sop_title: sop.title, category: sop.category, ...(typeof details === 'object' && details ? details : {}) },
      req.ip, req.headers['user-agent'] as string,
    )
    res.json({ success: true })
  } catch (err: any) {
    console.error('[my-space:sop-activity]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

export default router
