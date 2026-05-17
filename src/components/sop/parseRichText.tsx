import { Fragment, type ReactNode } from 'react'

/**
 * Parse simple markdown-style inline marks into React nodes.
 *
 * Syntaxe supportée :
 *  - **gras**
 *  - *italique*
 *  - __souligné__
 *  - ~barré~
 *  - `code inline`
 *  - [texte](url)            → lien
 *  - {{red}}texte{{/red}}    → texte coloré (red, green, blue, orange, gray)
 *
 * Sécurité : on échappe le texte en utilisant React (textContent), donc pas
 * d'injection HTML possible. Les URL sont normalisées via new URL().
 */
export function parseRichText(input: string | undefined | null): ReactNode {
  if (!input) return null
  return renderTokens(tokenize(String(input)))
}

type Token =
  | { kind: 'text'; value: string }
  | { kind: 'bold'; children: Token[] }
  | { kind: 'italic'; children: Token[] }
  | { kind: 'underline'; children: Token[] }
  | { kind: 'strike'; children: Token[] }
  | { kind: 'code'; value: string }
  | { kind: 'link'; href: string; children: Token[] }
  | { kind: 'color'; color: string; children: Token[] }

const COLOR_MAP: Record<string, string> = {
  red:    'text-rose-600 dark:text-rose-400',
  green:  'text-emerald-600 dark:text-emerald-400',
  blue:   'text-blue-600 dark:text-blue-400',
  orange: 'text-orange-600 dark:text-orange-400',
  gray:   'text-slate-500 dark:text-slate-400',
}

/* ── Tokenizer minimal ───────────────────────────────────────── */
function tokenize(s: string): Token[] {
  const out: Token[] = []
  let i = 0

  while (i < s.length) {
    /* code inline */
    if (s[i] === '`') {
      const end = s.indexOf('`', i + 1)
      if (end > i) {
        out.push({ kind: 'code', value: s.slice(i + 1, end) })
        i = end + 1
        continue
      }
    }
    /* gras **... */
    if (s.startsWith('**', i)) {
      const end = s.indexOf('**', i + 2)
      if (end > i) {
        out.push({ kind: 'bold', children: tokenize(s.slice(i + 2, end)) })
        i = end + 2
        continue
      }
    }
    /* souligné __... */
    if (s.startsWith('__', i)) {
      const end = s.indexOf('__', i + 2)
      if (end > i) {
        out.push({ kind: 'underline', children: tokenize(s.slice(i + 2, end)) })
        i = end + 2
        continue
      }
    }
    /* italique *... (un seul *) */
    if (s[i] === '*' && s[i + 1] !== '*') {
      const end = s.indexOf('*', i + 1)
      if (end > i) {
        out.push({ kind: 'italic', children: tokenize(s.slice(i + 1, end)) })
        i = end + 1
        continue
      }
    }
    /* barré ~... */
    if (s[i] === '~') {
      const end = s.indexOf('~', i + 1)
      if (end > i) {
        out.push({ kind: 'strike', children: tokenize(s.slice(i + 1, end)) })
        i = end + 1
        continue
      }
    }
    /* lien [texte](url) */
    if (s[i] === '[') {
      const closeBracket = s.indexOf(']', i + 1)
      if (closeBracket > i && s[closeBracket + 1] === '(') {
        const closeParen = s.indexOf(')', closeBracket + 2)
        if (closeParen > closeBracket) {
          const label = s.slice(i + 1, closeBracket)
          const rawHref = s.slice(closeBracket + 2, closeParen).trim()
          out.push({ kind: 'link', href: safeUrl(rawHref), children: tokenize(label) })
          i = closeParen + 1
          continue
        }
      }
    }
    /* couleur {{red}}...{{/red}} */
    if (s.startsWith('{{', i)) {
      const openEnd = s.indexOf('}}', i + 2)
      if (openEnd > i) {
        const tag = s.slice(i + 2, openEnd).toLowerCase()
        if (COLOR_MAP[tag]) {
          const closeTag = `{{/${tag}}}`
          const closeIdx = s.indexOf(closeTag, openEnd + 2)
          if (closeIdx > openEnd) {
            out.push({ kind: 'color', color: tag, children: tokenize(s.slice(openEnd + 2, closeIdx)) })
            i = closeIdx + closeTag.length
            continue
          }
        }
      }
    }

    /* texte brut — accumuler jusqu'au prochain marqueur */
    let j = i
    while (j < s.length && !isMarkerStart(s, j)) j++
    if (j === i) j = i + 1
    out.push({ kind: 'text', value: s.slice(i, j) })
    i = j
  }
  return out
}

function isMarkerStart(s: string, i: number): boolean {
  const c = s[i]
  if (c === '`' || c === '~' || c === '[') return true
  if (c === '*') return true
  if (s.startsWith('__', i)) return true
  if (s.startsWith('{{', i)) return true
  return false
}

function safeUrl(raw: string): string {
  try {
    const u = new URL(raw, 'https://example.invalid')
    if (u.protocol === 'http:' || u.protocol === 'https:' || u.protocol === 'mailto:' || u.protocol === 'tel:') {
      return raw.startsWith('http') || raw.startsWith('mailto:') || raw.startsWith('tel:') ? raw : u.toString()
    }
  } catch {
    /* ignore */
  }
  return '#'
}

/* ── Renderer ────────────────────────────────────────────────── */
function renderTokens(tokens: Token[]): ReactNode {
  return (
    <>
      {tokens.map((t, i) => <Fragment key={i}>{renderOne(t)}</Fragment>)}
    </>
  )
}

function renderOne(t: Token): ReactNode {
  switch (t.kind) {
    case 'text':      return t.value
    case 'bold':      return <strong className="font-bold">{renderTokens(t.children)}</strong>
    case 'italic':    return <em>{renderTokens(t.children)}</em>
    case 'underline': return <u>{renderTokens(t.children)}</u>
    case 'strike':    return <s>{renderTokens(t.children)}</s>
    case 'code':      return <code className="px-1 py-0.5 rounded bg-muted font-mono text-[0.92em] text-foreground">{t.value}</code>
    case 'link':      return <a href={t.href} target="_blank" rel="noopener noreferrer" className="text-blue-600 dark:text-blue-400 underline underline-offset-2 hover:opacity-80">{renderTokens(t.children)}</a>
    case 'color':     return <span className={COLOR_MAP[t.color]}>{renderTokens(t.children)}</span>
  }
}
