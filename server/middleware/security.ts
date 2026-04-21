import { Request, Response, NextFunction } from 'express'
import rateLimit from 'express-rate-limit'
import helmet from 'helmet'

/* ── Helmet — secure HTTP headers ─────────────────────────────── */
export { helmet }

/* ── Rate limiters ────────────────────────────────────────────── */

/** Auth endpoints: max 10 attempts per 15 min per IP */
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Trop de tentatives. Réessayez dans 15 minutes.' },
  skipSuccessfulRequests: true,
})

/** General API: 200 requests per minute per IP */
export const apiLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 200,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Limite de requêtes atteinte.' },
})

/** Password change: max 5 per hour */
export const passwordLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 5,
  message: { error: 'Trop de tentatives de changement de mot de passe.' },
})

/* ── Input sanitizer — strip dangerous characters ─────────────── */
export function sanitizeBody(req: Request, _res: Response, next: NextFunction) {
  function clean(val: unknown): unknown {
    if (typeof val === 'string') {
      return val
        .replace(/<script[\s\S]*?>[\s\S]*?<\/script>/gi, '')
        .replace(/javascript:/gi, '')
        .replace(/on\w+\s*=/gi, '')
        .trim()
    }
    if (Array.isArray(val)) return val.map(clean)
    if (val && typeof val === 'object') {
      return Object.fromEntries(Object.entries(val as object).map(([k, v]) => [k, clean(v)]))
    }
    return val
  }
  req.body = clean(req.body)
  next()
}

/* ── Column name validator — prevent SQL injection via orderBy ── */
const SAFE_COLUMN = /^[a-z_][a-z0-9_]{0,63}$/

export function safeColumn(col: string, fallback = 'created_at'): string {
  return SAFE_COLUMN.test(col) ? col : fallback
}

/* ── Error handler — never leak internals ─────────────────────── */
export function errorHandler(err: any, _req: Request, res: Response, _next: NextFunction) {
  const isDev = process.env.NODE_ENV !== 'production'
  console.error('[ERROR]', err)
  res.status(err.status ?? 500).json({
    error: isDev ? err.message : 'Une erreur est survenue',
    ...(isDev && { stack: err.stack }),
  })
}
