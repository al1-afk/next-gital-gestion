import { Request, Response, NextFunction } from 'express'
import jwt from 'jsonwebtoken'

const ACCESS_SECRET  = process.env.JWT_SECRET        || 'gestiq-access-secret-change-in-prod'
const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'gestiq-refresh-secret-change-in-prod'

export interface JwtPayload {
  userId:   string
  email:    string
  tenantId: string
  role:     string
}

declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload
    }
  }
}

export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization
  if (!header?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Non authentifié' })
  }
  try {
    const token = header.slice(7)
    const payload = jwt.verify(token, ACCESS_SECRET) as JwtPayload & { type?: string }
    // Refuse refresh tokens used as access tokens
    if (payload.type === 'refresh') {
      return res.status(401).json({ error: 'Token invalide' })
    }
    req.user = payload
    next()
  } catch (err: any) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expiré', code: 'TOKEN_EXPIRED' })
    }
    return res.status(401).json({ error: 'Token invalide' })
  }
}

/* Access token — 15 minutes */
export function signAccessToken(payload: JwtPayload): string {
  return jwt.sign({ ...payload, type: 'access' }, ACCESS_SECRET, { expiresIn: '15m' })
}

/* Refresh token — 7 days, stored as httpOnly cookie */
export function signRefreshToken(payload: Pick<JwtPayload, 'userId' | 'tenantId'>): string {
  return jwt.sign({ ...payload, type: 'refresh' }, REFRESH_SECRET, { expiresIn: '7d' })
}

export function verifyRefreshToken(token: string): (Pick<JwtPayload, 'userId' | 'tenantId'> & { type: string }) | null {
  try {
    return jwt.verify(token, REFRESH_SECRET) as any
  } catch {
    return null
  }
}

/* Legacy alias — used during migration */
export const signToken = signAccessToken

/* RBAC — role hierarchy */
const ROLE_RANK: Record<string, number> = { admin: 3, manager: 2, member: 1, viewer: 0 }

export function requireRole(minRole: 'admin' | 'manager' | 'member') {
  return (req: Request, res: Response, next: NextFunction) => {
    const rank = ROLE_RANK[req.user?.role ?? ''] ?? -1
    if (rank < ROLE_RANK[minRole]) {
      return res.status(403).json({ error: 'Permissions insuffisantes' })
    }
    next()
  }
}
