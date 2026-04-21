import { Router, Request, Response } from 'express'
import bcrypt from 'bcryptjs'
import crypto from 'crypto'
import { query, queryOne } from '../db/pool'
import {
  signAccessToken, signRefreshToken, verifyRefreshToken,
  requireAuth,
} from '../middleware/auth'
import { authLimiter, passwordLimiter } from '../middleware/security'

const router = Router()

/* ── Helpers ─────────────────────────────────────────────────── */

function hashToken(token: string): string {
  return crypto.createHash('sha256').update(token).digest('hex')
}

async function issueTokenPair(
  res: Response,
  user: { id: string; email: string; role: string; tenant_id: string; slug: string },
  ip: string,
  ua: string,
) {
  const accessToken  = signAccessToken({
    userId: user.id, email: user.email, tenantId: user.tenant_id, role: user.role,
  })
  const refreshToken = signRefreshToken({ userId: user.id, tenantId: user.tenant_id })
  const tokenHash    = hashToken(refreshToken)

  /* Store hashed refresh token — raw token NEVER written to DB */
  await query(
    `INSERT INTO refresh_tokens (user_id, tenant_id, token_hash, ip_address, user_agent, expires_at)
     VALUES ($1, $2, $3, $4, $5, NOW() + INTERVAL '7 days')`,
    [user.id, user.tenant_id, tokenHash, ip, ua]
  )

  /* httpOnly cookie — not readable by JS */
  res.cookie('gestiq_refresh', refreshToken, {
    httpOnly: true,
    secure:   process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge:   7 * 24 * 60 * 60 * 1000,
    path:     '/api/auth',
  })

  return { accessToken, tenantSlug: user.slug }
}

/* ── POST /api/auth/register ─────────────────────────────────── */
router.post('/register', authLimiter, async (req: Request, res: Response) => {
  const { email, password, name, tenantSlug, tenantName } = req.body

  if (!email || !password || !tenantSlug || !tenantName) {
    return res.status(400).json({ error: 'Tous les champs sont requis' })
  }
  if (password.length < 8) {
    return res.status(400).json({ error: 'Mot de passe: minimum 8 caractères' })
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return res.status(400).json({ error: 'Email invalide' })
  }

  const slug = tenantSlug.toLowerCase().replace(/[^a-z0-9-]/g, '-').slice(0, 63)

  try {
    const [existing, existingTenant] = await Promise.all([
      queryOne('SELECT id FROM users WHERE email = $1', [email]),
      queryOne('SELECT id FROM tenants WHERE slug = $1', [slug]),
    ])
    if (existing)       return res.status(409).json({ error: 'Email déjà utilisé' })
    if (existingTenant) return res.status(409).json({ error: 'Slug déjà pris' })

    const hash = await bcrypt.hash(password, 12)

    const user = await queryOne<{ id: string }>(
      `INSERT INTO users (email, password_hash, name) VALUES ($1, $2, $3) RETURNING id`,
      [email, hash, name ?? email]
    )
    const tenant = await queryOne<{ id: string }>(
      `INSERT INTO tenants (slug, name, owner_id) VALUES ($1, $2, $3) RETURNING id`,
      [slug, tenantName, user!.id]
    )
    await query(
      `INSERT INTO tenant_users (tenant_id, user_id, role, status) VALUES ($1, $2, 'admin', 'active')`,
      [tenant!.id, user!.id]
    )

    const { accessToken, tenantSlug: s } = await issueTokenPair(
      res,
      { id: user!.id, email, role: 'admin', tenant_id: tenant!.id, slug },
      req.ip ?? '',
      req.headers['user-agent'] ?? '',
    )

    res.status(201).json({ token: accessToken, tenantSlug: s, tenantId: tenant!.id })
  } catch (err: any) {
    console.error('[register]', err.message)
    res.status(500).json({ error: 'Erreur lors de l\'inscription' })
  }
})

/* ── POST /api/auth/login ────────────────────────────────────── */
router.post('/login', authLimiter, async (req: Request, res: Response) => {
  const { email, password, tenantSlug } = req.body
  if (!email || !password) {
    return res.status(400).json({ error: 'Email et mot de passe requis' })
  }

  try {
    /* Brute-force: count recent failures from this IP + email */
    const recentFails = await queryOne<{ count: string }>(
      `SELECT COUNT(*)::int as count FROM login_attempts
       WHERE (email = $1 OR ip_address = $2::inet)
         AND success = false
         AND attempted_at > NOW() - INTERVAL '15 minutes'`,
      [email, req.ip ?? '0.0.0.0']
    )
    if (Number(recentFails?.count ?? 0) >= 10) {
      return res.status(429).json({
        error: 'Compte temporairement verrouillé. Réessayez dans 15 minutes.',
      })
    }

    const user = await queryOne<{ id: string; password_hash: string; name: string; is_active: boolean }>(
      `SELECT id, password_hash, name, is_active FROM users WHERE email = $1`, [email]
    )

    const valid = user ? await bcrypt.compare(password, user.password_hash) : false

    /* Always log attempt */
    await query(
      `INSERT INTO login_attempts (email, ip_address, success) VALUES ($1, $2::inet, $3)`,
      [email, req.ip ?? '0.0.0.0', valid]
    )

    if (!user || !valid) {
      return res.status(401).json({ error: 'Identifiants incorrects' })
    }
    if (!user.is_active) {
      return res.status(403).json({ error: 'Compte désactivé' })
    }

    let memberRow: any
    if (tenantSlug) {
      memberRow = await queryOne(
        `SELECT tu.tenant_id, tu.role, t.slug
         FROM tenant_users tu JOIN tenants t ON t.id = tu.tenant_id
         WHERE tu.user_id = $1 AND t.slug = $2 AND tu.status = 'active'`,
        [user.id, tenantSlug]
      )
    } else {
      memberRow = await queryOne(
        `SELECT tu.tenant_id, tu.role, t.slug
         FROM tenant_users tu JOIN tenants t ON t.id = tu.tenant_id
         WHERE tu.user_id = $1 AND tu.status = 'active'
         ORDER BY tu.invited_at LIMIT 1`,
        [user.id]
      )
    }

    if (!memberRow) return res.status(403).json({ error: 'Accès refusé' })

    const { accessToken, tenantSlug: s } = await issueTokenPair(
      res,
      { id: user.id, email, role: memberRow.role, tenant_id: memberRow.tenant_id, slug: memberRow.slug },
      req.ip ?? '',
      req.headers['user-agent'] ?? '',
    )

    res.json({ token: accessToken, tenantSlug: s, tenantId: memberRow.tenant_id, role: memberRow.role })
  } catch (err: any) {
    console.error('[login]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* ── POST /api/auth/refresh — Rotation: old token revoked ─────── */
router.post('/refresh', authLimiter, async (req: Request, res: Response) => {
  const rawToken = req.cookies?.gestiq_refresh
  if (!rawToken) return res.status(401).json({ error: 'Session expirée', code: 'NO_REFRESH' })

  const payload = verifyRefreshToken(rawToken)
  if (!payload) {
    res.clearCookie('gestiq_refresh', { path: '/api/auth' })
    return res.status(401).json({ error: 'Session invalide', code: 'INVALID_REFRESH' })
  }

  const tokenHash = hashToken(rawToken)

  try {
    /* Find + atomically revoke the token in one query */
    const stored = await queryOne<{ id: string; revoked: boolean; expires_at: string }>(
      `UPDATE refresh_tokens
       SET revoked = true
       WHERE token_hash = $1 AND revoked = false AND expires_at > NOW()
       RETURNING id, revoked, expires_at`,
      [tokenHash]
    )

    if (!stored) {
      /* Token reuse detected — revoke ALL tokens for this user (session hijack attempt) */
      await query(
        `UPDATE refresh_tokens SET revoked = true WHERE user_id = $1`,
        [payload.userId]
      )
      res.clearCookie('gestiq_refresh', { path: '/api/auth' })
      return res.status(401).json({ error: 'Session compromise détectée', code: 'TOKEN_REUSE' })
    }

    const row = await queryOne<{ id: string; email: string; role: string; tenant_id: string; slug: string }>(
      `SELECT u.id, u.email, tu.role, tu.tenant_id, t.slug
       FROM users u
       JOIN tenant_users tu ON tu.user_id = u.id
       JOIN tenants t ON t.id = tu.tenant_id
       WHERE u.id = $1 AND tu.tenant_id = $2 AND tu.status = 'active' AND u.is_active = true`,
      [payload.userId, payload.tenantId]
    )
    if (!row) {
      res.clearCookie('gestiq_refresh', { path: '/api/auth' })
      return res.status(401).json({ error: 'Utilisateur introuvable' })
    }

    const { accessToken } = await issueTokenPair(
      res, row, req.ip ?? '', req.headers['user-agent'] ?? ''
    )

    res.json({ token: accessToken })
  } catch (err: any) {
    console.error('[refresh]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* ── POST /api/auth/logout ───────────────────────────────────── */
router.post('/logout', requireAuth, async (req: Request, res: Response) => {
  const rawToken = req.cookies?.gestiq_refresh
  if (rawToken) {
    const tokenHash = hashToken(rawToken)
    await query(
      `UPDATE refresh_tokens SET revoked = true WHERE token_hash = $1`,
      [tokenHash]
    ).catch(() => {})
  }
  res.clearCookie('gestiq_refresh', { path: '/api/auth' })
  res.json({ success: true })
})

/* ── POST /api/auth/change-password ─────────────────────────── */
router.post('/change-password', requireAuth, passwordLimiter, async (req: Request, res: Response) => {
  const { currentPassword, newPassword } = req.body
  if (!currentPassword || !newPassword) {
    return res.status(400).json({ error: 'Les deux mots de passe sont requis' })
  }
  if (newPassword.length < 8) {
    return res.status(400).json({ error: 'Minimum 8 caractères requis' })
  }

  try {
    const user = await queryOne<{ password_hash: string }>(
      'SELECT password_hash FROM users WHERE id = $1', [req.user!.userId]
    )
    if (!user) return res.status(404).json({ error: 'Utilisateur introuvable' })

    const valid = await bcrypt.compare(currentPassword, user.password_hash)
    if (!valid) return res.status(400).json({ error: 'Mot de passe actuel incorrect' })

    const hash = await bcrypt.hash(newPassword, 12)
    await query('UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2', [hash, req.user!.userId])

    /* Revoke ALL refresh tokens — force re-login on all devices */
    await query(
      `UPDATE refresh_tokens SET revoked = true WHERE user_id = $1`,
      [req.user!.userId]
    )
    res.clearCookie('gestiq_refresh', { path: '/api/auth' })

    res.json({ success: true })
  } catch (err: any) {
    console.error('[change-password]', err.message)
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

/* ── GET /api/auth/me ────────────────────────────────────────── */
router.get('/me', requireAuth, async (req: Request, res: Response) => {
  const { userId, tenantId } = req.user!
  try {
    const user = await queryOne(
      `SELECT u.id, u.email, u.name, tu.role, t.slug, t.name as tenant_name, t.plan
       FROM users u
       JOIN tenant_users tu ON tu.user_id = u.id
       JOIN tenants t ON t.id = tu.tenant_id
       WHERE u.id = $1 AND tu.tenant_id = $2 AND u.is_active = true`,
      [userId, tenantId]
    )
    if (!user) return res.status(401).json({ error: 'Session invalide' })
    res.json(user)
  } catch (err: any) {
    res.status(500).json({ error: 'Erreur serveur' })
  }
})

export default router
