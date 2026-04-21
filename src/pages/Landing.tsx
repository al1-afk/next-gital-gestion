import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { CheckCircle, Users, FileText, CreditCard, AlertCircle, Loader2 } from 'lucide-react'
import { authApi, tokenStore } from '@/lib/api'

function slugify(str: string) {
  return str
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')
    .replace(/[^a-z0-9-]/g, '')
    .slice(0, 30)
}

export default function Landing() {
  const navigate = useNavigate()
  const [email, setEmail]         = useState('')
  const [password, setPassword]   = useState('')
  const [name, setName]           = useState('')
  const [company, setCompany]     = useState('')
  const [loading, setLoading]     = useState(false)
  const [error, setError]         = useState<string | null>(null)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)
    if (password.length < 8) {
      setError('Le mot de passe doit contenir au moins 8 caractères')
      return
    }
    const tenantName = company.trim() || name.trim()
    const tenantSlug = slugify(tenantName) || 'mon-espace'

    setLoading(true)
    try {
      const res = await authApi.register({ email, password, name, tenantSlug, tenantName })
      tokenStore.set(res.token)
      sessionStorage.setItem('gestiq_tenant_slug', res.tenantSlug)
      navigate(`/${res.tenantSlug}`, { replace: true })
    } catch (err: any) {
      setError(err.message || 'Une erreur est survenue')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-[#020617] text-slate-100">

      {/* ── Nav ─────────────────────────────────────────────── */}
      <nav className="border-b border-slate-800 px-6 py-4 flex items-center justify-between max-w-6xl mx-auto">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center">
            <span className="text-white font-bold text-sm">G</span>
          </div>
          <span className="font-bold text-white text-lg">GestiQ</span>
        </div>
        <a href="/auth" className="text-sm text-slate-400 hover:text-white transition-colors">
          Se connecter
        </a>
      </nav>

      {/* ── Hero ────────────────────────────────────────────── */}
      <section className="max-w-6xl mx-auto px-6 pt-20 pb-16 grid lg:grid-cols-2 gap-12 items-center">
        <div>
          <div className="inline-flex items-center gap-2 bg-blue-600/10 border border-blue-600/20 rounded-full px-3 py-1 text-xs text-blue-400 mb-6">
            <span className="w-1.5 h-1.5 rounded-full bg-blue-400 animate-pulse" />
            Gratuit pour commencer — aucune carte requise
          </div>
          <h1 className="text-4xl lg:text-5xl font-bold text-white leading-tight mb-4">
            Gérez vos clients et factures en 1 minute —{' '}
            <span className="text-blue-400">sans Excel</span>
          </h1>
          <p className="text-slate-400 text-lg mb-8">
            Simple, rapide, et adapté aux petites entreprises.
            Tout ce dont vous avez besoin, rien de plus.
          </p>
          <div className="flex flex-wrap gap-3">
            {['Sans formation', 'Données sécurisées', 'Support réactif'].map(f => (
              <span key={f} className="flex items-center gap-1.5 text-sm text-slate-400">
                <CheckCircle className="w-4 h-4 text-blue-500 shrink-0" />
                {f}
              </span>
            ))}
          </div>
        </div>

        {/* ── Signup form ─────────────────────────────────── */}
        <div className="bg-slate-900 border border-slate-700/60 rounded-2xl p-8 shadow-2xl">
          <h2 className="text-xl font-bold text-white mb-1">Créer mon compte gratuit</h2>
          <p className="text-slate-500 text-sm mb-6">Prêt en 60 secondes</p>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid sm:grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-medium text-slate-400 mb-1">Votre prénom *</label>
                <input
                  type="text"
                  value={name}
                  onChange={e => setName(e.target.value)}
                  placeholder="Ahmed"
                  required
                  className="w-full bg-slate-800 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 transition-colors"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-slate-400 mb-1">Nom de l'entreprise</label>
                <input
                  type="text"
                  value={company}
                  onChange={e => setCompany(e.target.value)}
                  placeholder="Mon Entreprise"
                  className="w-full bg-slate-800 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 transition-colors"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-medium text-slate-400 mb-1">Email *</label>
              <input
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                placeholder="vous@email.com"
                required
                className="w-full bg-slate-800 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 transition-colors"
              />
            </div>

            <div>
              <label className="block text-xs font-medium text-slate-400 mb-1">Mot de passe *</label>
              <input
                type="password"
                value={password}
                onChange={e => setPassword(e.target.value)}
                placeholder="8 caractères minimum"
                required
                className="w-full bg-slate-800 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 transition-colors"
              />
            </div>

            {error && (
              <div className="flex items-center gap-2 bg-red-500/10 border border-red-500/30 rounded-lg px-3 py-2 text-sm text-red-400">
                <AlertCircle className="w-4 h-4 shrink-0" />
                {error}
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-blue-600 hover:bg-blue-500 disabled:opacity-60 text-white font-semibold py-3 rounded-lg text-sm transition-colors flex items-center justify-center gap-2"
            >
              {loading ? (
                <><Loader2 className="w-4 h-4 animate-spin" /> Création en cours...</>
              ) : (
                'Créer mon compte gratuit →'
              )}
            </button>
          </form>

          <p className="text-center text-xs text-slate-600 mt-4">
            Pas de carte bancaire · Annulable à tout moment
          </p>
        </div>
      </section>

      {/* ── Problèmes ───────────────────────────────────────── */}
      <section className="border-t border-slate-800 py-16">
        <div className="max-w-6xl mx-auto px-6">
          <p className="text-center text-slate-500 text-sm uppercase tracking-wider mb-10">
            Vous reconnaissez-vous ?
          </p>
          <div className="grid md:grid-cols-3 gap-6">
            {[
              {
                emoji: '😤',
                title: 'Excel pour tout',
                desc: 'Des fichiers partout, des versions incohérentes, des erreurs qui coûtent cher.',
              },
              {
                emoji: '⏳',
                title: 'Factures manuelles',
                desc: 'Vous perdez des heures à copier-coller les mêmes informations pour chaque client.',
              },
              {
                emoji: '😰',
                title: 'Paiements oubliés',
                desc: 'Vous ne savez plus qui a payé, qui doit encore payer, combien reste à encaisser.',
              },
            ].map(p => (
              <div key={p.title} className="bg-slate-900/50 border border-slate-800 rounded-xl p-6">
                <div className="text-3xl mb-3">{p.emoji}</div>
                <h3 className="font-semibold text-white mb-2">{p.title}</h3>
                <p className="text-slate-400 text-sm leading-relaxed">{p.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── Solution ────────────────────────────────────────── */}
      <section className="py-16">
        <div className="max-w-6xl mx-auto px-6">
          <h2 className="text-2xl font-bold text-white text-center mb-2">
            GestiQ règle ça en 3 modules
          </h2>
          <p className="text-slate-500 text-center text-sm mb-12">
            Pas de configuration. Pas de formation. Utilisable dès la première minute.
          </p>
          <div className="grid md:grid-cols-3 gap-6">
            {[
              {
                icon: Users,
                title: 'Clients',
                desc: 'Centralisez tous vos clients en un seul endroit. Historique, contacts, notes — tout accessible en un clic.',
                color: 'blue',
              },
              {
                icon: FileText,
                title: 'Factures',
                desc: 'Créez et envoyez des factures professionnelles en moins de 2 minutes. PDF prêt à envoyer.',
                color: 'emerald',
              },
              {
                icon: CreditCard,
                title: 'Paiements',
                desc: 'Suivez ce qui est payé, ce qui est en attente. Sachez exactement où en est votre trésorerie.',
                color: 'violet',
              },
            ].map(f => {
              const Icon = f.icon
              const colors: Record<string, string> = {
                blue:    'bg-blue-600/10 text-blue-400 border-blue-600/20',
                emerald: 'bg-emerald-600/10 text-emerald-400 border-emerald-600/20',
                violet:  'bg-violet-600/10 text-violet-400 border-violet-600/20',
              }
              return (
                <div key={f.title} className="bg-slate-900 border border-slate-800 rounded-xl p-6 hover:border-slate-700 transition-colors">
                  <div className={`w-10 h-10 rounded-lg border flex items-center justify-center mb-4 ${colors[f.color]}`}>
                    <Icon className="w-5 h-5" />
                  </div>
                  <h3 className="font-semibold text-white mb-2">{f.title}</h3>
                  <p className="text-slate-400 text-sm leading-relaxed">{f.desc}</p>
                </div>
              )
            })}
          </div>
        </div>
      </section>

      {/* ── Screenshot ──────────────────────────────────────── */}
      <section className="py-16 border-t border-slate-800">
        <div className="max-w-5xl mx-auto px-6 text-center">
          <h2 className="text-2xl font-bold text-white mb-3">Votre tableau de bord en temps réel</h2>
          <p className="text-slate-500 text-sm mb-10">Vue d'ensemble claire — chiffres, alertes, tâches</p>
          <div className="rounded-xl overflow-hidden border border-slate-700/60 shadow-2xl shadow-blue-900/10">
            <img
              src="/dashboard-preview.png"
              alt="GestiQ Dashboard"
              className="w-full object-cover"
              onError={e => {
                (e.target as HTMLImageElement).style.display = 'none'
              }}
            />
            <div className="bg-slate-900 p-12 flex items-center justify-center text-slate-600 text-sm hidden only:flex">
              Aperçu du dashboard
            </div>
          </div>
        </div>
      </section>

      {/* ── Final CTA ───────────────────────────────────────── */}
      <section className="py-20 border-t border-slate-800">
        <div className="max-w-2xl mx-auto px-6 text-center">
          <h2 className="text-3xl font-bold text-white mb-4">
            Prêt à gagner du temps chaque semaine ?
          </h2>
          <p className="text-slate-400 mb-8">
            Rejoignez des centaines de petites entreprises qui ont arrêté Excel.
          </p>
          <a
            href="#top"
            onClick={e => {
              e.preventDefault()
              window.scrollTo({ top: 0, behavior: 'smooth' })
            }}
            className="inline-block bg-blue-600 hover:bg-blue-500 text-white font-semibold px-8 py-3 rounded-lg text-sm transition-colors"
          >
            Créer mon compte gratuit →
          </a>
          <p className="text-xs text-slate-600 mt-4">Sans carte bancaire · Sans engagement</p>
        </div>
      </section>

      {/* ── Footer ──────────────────────────────────────────── */}
      <footer className="border-t border-slate-800 py-6 text-center text-xs text-slate-600">
        © 2025 GestiQ — Tous droits réservés
      </footer>
    </div>
  )
}
