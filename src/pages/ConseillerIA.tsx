import { useState, useMemo, useRef, useEffect } from 'react'
import { motion } from 'framer-motion'
import {
  Bot, Send, Sparkles, TrendingUp, AlertTriangle, Target,
  RefreshCw, User, Loader2, DollarSign, Activity, Zap,
} from 'lucide-react'
import { useProspects } from '@/hooks/useProspects'
import { useFactures }  from '@/hooks/useFactures'
import { useDepenses }  from '@/hooks/useDepenses'
import { Button } from '@/components/ui/button'
import { Badge }  from '@/components/ui/badge'
import { formatCurrency } from '@/lib/utils'
import {
  computeCashFlowProjection,
  detectAnomalies,
  computePipelineMetrics,
} from '@/lib/intelligence'

interface Message {
  role: 'user' | 'assistant'
  content: string
}

function buildContext(
  prospects: ReturnType<typeof useProspects>['data'],
  factures:  ReturnType<typeof useFactures>['data'],
  depenses:  ReturnType<typeof useDepenses>['data'],
): string {
  const p = prospects ?? []
  const f = factures  ?? []
  const d = depenses  ?? []

  const metrics    = computePipelineMetrics(p)
  const cashflow   = computeCashFlowProjection(f, d)
  const anomalies  = detectAnomalies(f, p, d)

  const pipelineTotal = p.filter(x => !['perdu'].includes(x.statut))
    .reduce((s, x) => s + (x.valeur_estimee ?? 0), 0)

  const overdue = f.filter(x => {
    if (x.statut !== 'impayee' || !x.date_echeance) return false
    return new Date(x.date_echeance) < new Date()
  })

  const toRelance = p.filter(x => !['gagne', 'perdu'].includes(x.statut) && x.date_relance)
    .filter(x => new Date(x.date_relance!) <= new Date())
    .sort((a, b) => (b.valeur_estimee ?? 0) - (a.valeur_estimee ?? 0))

  const convRate = metrics.funnelData[0]?.rate ?? 0

  return `
DONNÉES TEMPS RÉEL (${new Date().toLocaleDateString('fr-FR')}):
- Pipeline actif: ${formatCurrency(pipelineTotal)} (${p.filter(x => !['perdu','gagne'].includes(x.statut)).length} prospects actifs)
- Taux conversion global: ${convRate}%
- Factures impayées en retard: ${overdue.length} (${formatCurrency(overdue.reduce((s, x) => s + (x.montant_ttc - x.montant_paye), 0))})
- Trésorerie prévue 30j: ${formatCurrency(cashflow.next30Days)}
- Dépenses moy/mois: ${formatCurrency(cashflow.avgMonthlyExpenses)}
- Anomalies détectées: ${anomalies.map(a => a.title).join(', ') || 'Aucune'}
- Prospects à relancer maintenant: ${toRelance.slice(0, 5).map(x => `${x.nom} (${formatCurrency(x.valeur_estimee ?? 0)})`).join(', ') || 'Aucun'}
- Top sources: ${metrics.sourceData.slice(0, 3).map(s => `${s.source}: ${s.conversion}% conv`).join(', ')}
`.trim()
}

function generateReply(
  text: string,
  ctx: { prospects: any[]; factures: any[]; depenses: any[] },
): string {
  const p = ctx.prospects
  const f = ctx.factures
  const d = ctx.depenses

  const metrics   = computePipelineMetrics(p)
  const cashflow  = computeCashFlowProjection(f, d)
  const anomalies = detectAnomalies(f, p, d)
  const lower     = text.toLowerCase()

  const toRelance = p
    .filter(x => !['gagne', 'perdu'].includes(x.statut) && x.date_relance)
    .filter(x => new Date(x.date_relance!) <= new Date())
    .sort((a, b) => (b.valeur_estimee ?? 0) - (a.valeur_estimee ?? 0))

  const overdue = f.filter(x =>
    x.statut === 'impayee' && x.date_echeance && new Date(x.date_echeance) < new Date()
  )

  // Relances
  if (lower.includes('relance') || lower.includes('relancer') || lower.includes('priorité')) {
    if (toRelance.length === 0) {
      return `Bonne nouvelle : aucun prospect ne nécessite de relance immédiate.\n\nContinuez à alimenter votre pipeline avec de nouveaux contacts.`
    }
    const lines = toRelance.slice(0, 5).map((x, i) => {
      const daysLate = x.date_relance
        ? Math.floor((Date.now() - new Date(x.date_relance).getTime()) / 86400000)
        : 0
      return `${i + 1}. **${x.nom}** (${x.entreprise ?? 'Indépendant'}) — ${formatCurrency(x.valeur_estimee ?? 0)}\n   Statut: ${x.statut} · En retard de ${daysLate}j\n   → ${x.statut === 'proposition' ? 'Relancez sur le devis' : 'Appel de qualification'}`
    })
    return `**Prospects à relancer en priorité :**\n\n${lines.join('\n\n')}\n\nTotal: ${formatCurrency(toRelance.reduce((s, x) => s + (x.valeur_estimee ?? 0), 0))} en jeu.`
  }

  // Pipeline
  if (lower.includes('pipeline') || lower.includes('analyse') || lower.includes('bilan')) {
    const active = p.filter(x => !['perdu', 'gagne'].includes(x.statut))
    const won    = p.filter(x => x.statut === 'gagne')
    const lost   = p.filter(x => x.statut === 'perdu')
    return `**Analyse pipeline :**\n\n📊 ${p.length} prospects total · ${active.length} actifs\n✅ ${won.length} gagnés · ❌ ${lost.length} perdus\n💰 Valeur active: ${formatCurrency(active.reduce((s,x)=>s+(x.valeur_estimee??0),0))}\n\n**Entonnoir:**\n${metrics.funnelData.map(s => `• ${s.stage}: ${s.count} (→ ${s.rate}% conv)`).join('\n')}\n\n**Top sources:**\n${metrics.sourceData.slice(0,4).map(s=>`• ${s.source}: ${s.leads} leads, ${s.conversion}% conversion`).join('\n')}`
  }

  // Trésorerie / cash
  if (lower.includes('trésorerie') || lower.includes('cash') || lower.includes('argent') || lower.includes('finances')) {
    return `**Projection trésorerie :**\n\n📅 7 prochains jours: ${formatCurrency(cashflow.next7Days)}\n📅 30 prochains jours: ${formatCurrency(cashflow.next30Days)}\n\n📥 Entrées attendues: ${formatCurrency(cashflow.expectedInflows)}\n📤 Dépenses prévues: ${formatCurrency(cashflow.expectedOutflows)}\n💸 Délai moyen de paiement: ${cashflow.avgDaysToPay}j\n\n${cashflow.next30Days < 0 ? '⚠️ **Flux négatif prévu** — accélérez vos relances de factures.' : '✅ Flux positif sur 30 jours.'}`
  }

  // Factures impayées
  if (lower.includes('facture') || lower.includes('impayé') || lower.includes('retard')) {
    if (overdue.length === 0) return `Aucune facture en retard. Excellente gestion du recouvrement !`
    const lines = overdue.slice(0, 5).map((x, i) => {
      const days = Math.floor((Date.now() - new Date(x.date_echeance!).getTime()) / 86400000)
      return `${i+1}. **${x.numero}** — ${formatCurrency(x.montant_ttc - x.montant_paye)} — ${days}j de retard`
    })
    return `**Factures impayées en retard :**\n\n${lines.join('\n')}\n\nTotal à recouvrer: ${formatCurrency(overdue.reduce((s,x)=>s+(x.montant_ttc-x.montant_paye),0))}\n\n→ Envoyez des relances formelles pour les factures > 30j.`
  }

  // Anomalies / risques
  if (lower.includes('risque') || lower.includes('anomalie') || lower.includes('alerte') || lower.includes('problème')) {
    if (anomalies.length === 0) return `Aucune anomalie détectée dans vos données. Continuez ainsi !`
    return `**Anomalies détectées (${anomalies.length}) :**\n\n${anomalies.map((a, i) => `${i+1}. **[${a.severity.toUpperCase()}]** ${a.title}\n   ${a.message}\n   → ${a.recommendation}`).join('\n\n')}`
  }

  // Taux de conversion
  if (lower.includes('conversion') || lower.includes('taux')) {
    const won  = p.filter(x => x.statut === 'gagne').length
    const rate = p.length > 0 ? (won / p.length * 100).toFixed(1) : '0'
    return `**Taux de conversion :**\n\nGlobal: ${rate}% (${won}/${p.length})\n\n**Par source:**\n${metrics.sourceData.map(s=>`• ${s.source}: ${s.conversion}% (${s.won}/${s.leads} leads)`).join('\n')}\n\n${Number(rate) < 15 ? '⚠️ Taux < 15% — révisez votre processus de qualification.' : '✅ Bon taux de conversion.'}`
  }

  // Recommandations générales
  const topActions: string[] = []
  if (toRelance.length > 0) topActions.push(`Relancer ${toRelance.length} prospect(s) (${formatCurrency(toRelance.slice(0,5).reduce((s,x)=>s+(x.valeur_estimee??0),0))} en jeu)`)
  if (overdue.length > 0)   topActions.push(`Recouvrer ${overdue.length} facture(s) impayée(s) en retard`)
  if (anomalies.some(a => a.severity === 'critical')) topActions.push(`Traiter ${anomalies.filter(a=>a.severity==='critical').length} anomalie(s) critique(s)`)
  if (cashflow.next30Days < 0) topActions.push('Améliorer les flux de trésorerie (prévision négative)')

  if (topActions.length === 0) {
    return `Votre activité semble saine. Voici des pistes de croissance :\n\n• Sourcez de nouveaux prospects via vos canaux les plus performants\n• Proposez des upsells à vos clients actifs\n• Mettez en place des abonnements récurrents pour stabiliser vos revenus\n\nBesoin d'une analyse spécifique ?`
  }

  return `**Actions prioritaires pour aujourd'hui :**\n\n${topActions.map((a,i)=>`${i+1}. ${a}`).join('\n')}\n\nTapez une question précise pour une analyse détaillée.`
}

export default function ConseillerIA() {
  const { data: prospects = [] } = useProspects()
  const { data: factures  = [] } = useFactures()
  const { data: depenses  = [] } = useDepenses()

  const context = useMemo(
    () => buildContext(prospects, factures, depenses),
    [prospects, factures, depenses],
  )

  const metrics   = useMemo(() => computePipelineMetrics(prospects), [prospects])
  const cashflow  = useMemo(() => computeCashFlowProjection(factures, depenses), [factures, depenses])
  const anomalies = useMemo(() => detectAnomalies(factures, prospects, depenses), [factures, prospects, depenses])

  const pipelineValue = prospects
    .filter(p => !['perdu'].includes(p.statut))
    .reduce((s, p) => s + (p.valeur_estimee ?? 0), 0)

  const [messages, setMessages] = useState<Message[]>(() => [{
    role: 'assistant',
    content: `Bonjour ! Je suis votre conseiller IA.\n\nJ'ai analysé vos données :\n• Pipeline: ${formatCurrency(pipelineValue)} actif\n• Trésorerie prévue 30j: ${formatCurrency(0)}\n• ${anomalies.length} anomalie(s) détectée(s)\n\nComment puis-je vous aider ?`,
  }])
  const [input, setInput]   = useState('')
  const [loading, setLoading] = useState(false)
  const bottomRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages, loading])

  // Update greeting when data loads
  useEffect(() => {
    if (prospects.length > 0 || factures.length > 0) {
      setMessages([{
        role: 'assistant',
        content: `Bonjour ! J'ai analysé vos données en temps réel :\n\n• Pipeline actif: ${formatCurrency(pipelineValue)}\n• Trésorerie prévue 30j: ${formatCurrency(cashflow.next30Days)}\n• ${anomalies.length} anomalie(s) détectée(s)\n\nComment puis-je vous aider ?`,
      }])
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [prospects.length, factures.length])

  const QUICK_QUESTIONS = [
    'Quels prospects relancer en priorité ?',
    'Analyse mon pipeline',
    'Quel est mon taux de conversion ?',
    'Analyse ma trésorerie',
    'Quels risques détectes-tu ?',
  ]

  const sendMessage = async (text: string) => {
    if (!text.trim() || loading) return
    setMessages(prev => [...prev, { role: 'user', content: text }])
    setInput('')
    setLoading(true)
    await new Promise(r => setTimeout(r, 800))
    const reply = generateReply(text, { prospects, factures, depenses })
    setMessages(prev => [...prev, { role: 'assistant', content: reply }])
    setLoading(false)
  }

  const insightCards = [
    {
      icon: AlertTriangle,
      color: 'red',
      title: `${anomalies.filter(a => a.severity === 'critical').length} anomalie(s) critique(s)`,
      desc: anomalies.filter(a => a.severity === 'critical')[0]?.title ?? 'Aucune anomalie critique détectée',
      question: 'Quels risques détectes-tu ?',
    },
    {
      icon: TrendingUp,
      color: 'emerald',
      title: `Pipeline ${formatCurrency(pipelineValue)}`,
      desc: `${prospects.filter(p => !['perdu','gagne'].includes(p.statut)).length} prospects actifs · Conv. ${metrics.funnelData[0]?.rate ?? 0}%`,
      question: 'Analyse mon pipeline',
    },
    {
      icon: DollarSign,
      color: 'blue',
      title: `Trésorerie +30j: ${formatCurrency(cashflow.next30Days)}`,
      desc: `Entrées: ${formatCurrency(cashflow.expectedInflows)} · Dépenses: ${formatCurrency(cashflow.expectedOutflows)}`,
      question: 'Analyse ma trésorerie',
    },
  ]

  const colorMap: Record<string, string> = {
    red:     'border-red-500/20 hover:border-red-500/40',
    emerald: 'border-emerald-500/20 hover:border-emerald-500/40',
    blue:    'border-blue-500/20 hover:border-blue-500/40',
  }
  const iconBgMap: Record<string, string> = {
    red:     'bg-red-500/20',
    emerald: 'bg-emerald-500/20',
    blue:    'bg-blue-500/20',
  }
  const iconColorMap: Record<string, string> = {
    red:     'text-red-500',
    emerald: 'text-emerald-500',
    blue:    'text-blue-500',
  }

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="page-header">
        <div>
          <h1 className="page-title flex items-center gap-2">
            <Bot className="w-7 h-7 text-blue-600 dark:text-blue-400" />
            Conseiller IA Commercial
          </h1>
          <p className="text-muted-foreground text-sm mt-1">Analyse intelligente basée sur vos données réelles</p>
        </div>
        <div className="flex items-center gap-2">
          <Badge variant="outline" className="text-emerald-600 border-emerald-500/40 bg-emerald-50 dark:bg-emerald-950/30 text-xs">
            <Activity className="w-3 h-3 mr-1" />
            Données live
          </Badge>
          <Button variant="secondary" size="sm" onClick={() => {
            setMessages([{ role: 'assistant', content: `Nouvelle session. ${context}\n\nComment puis-je vous aider ?` }])
          }}>
            <RefreshCw className="w-4 h-4" /> Actualiser
          </Button>
        </div>
      </div>

      {/* Insight cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {insightCards.map((card, idx) => (
          <motion.div
            key={idx}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: idx * 0.08 }}
            className={`card-premium p-4 cursor-pointer transition-all ${colorMap[card.color]}`}
            onClick={() => sendMessage(card.question)}
          >
            <div className="flex items-center gap-2 mb-2">
              <div className={`w-8 h-8 rounded-lg ${iconBgMap[card.color]} flex items-center justify-center`}>
                <card.icon className={`w-4 h-4 ${iconColorMap[card.color]}`} />
              </div>
              <span className="text-sm font-semibold text-foreground truncate">{card.title}</span>
            </div>
            <p className="text-xs text-muted-foreground leading-relaxed line-clamp-2">{card.desc}</p>
          </motion.div>
        ))}
      </div>

      {/* Chat window */}
      <div className="card-premium overflow-hidden flex flex-col" style={{ height: '520px' }}>
        <div className="flex-1 overflow-y-auto p-4 space-y-4">
          {messages.map((msg, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 8 }}
              animate={{ opacity: 1, y: 0 }}
              className={`flex gap-3 ${msg.role === 'user' ? 'flex-row-reverse' : ''}`}
            >
              <div className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${msg.role === 'assistant' ? 'bg-blue-600' : 'bg-slate-600'}`}>
                {msg.role === 'assistant'
                  ? <Bot className="w-4 h-4 text-white" />
                  : <User className="w-4 h-4 text-white" />}
              </div>
              <div className={`max-w-[78%] px-4 py-3 rounded-2xl text-sm leading-relaxed ${
                msg.role === 'assistant'
                  ? 'bg-muted text-foreground rounded-tl-sm'
                  : 'bg-blue-600 text-white rounded-tr-sm'
              }`}>
                <pre className="whitespace-pre-wrap font-sans">{msg.content}</pre>
              </div>
            </motion.div>
          ))}
          {loading && (
            <div className="flex gap-3">
              <div className="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center">
                <Bot className="w-4 h-4 text-white" />
              </div>
              <div className="bg-muted rounded-2xl rounded-tl-sm px-4 py-3">
                <div className="flex items-center gap-1">
                  <div className="w-2 h-2 bg-blue-400 rounded-full animate-bounce" />
                  <div className="w-2 h-2 bg-blue-400 rounded-full animate-bounce [animation-delay:0.1s]" />
                  <div className="w-2 h-2 bg-blue-400 rounded-full animate-bounce [animation-delay:0.2s]" />
                </div>
              </div>
            </div>
          )}
          <div ref={bottomRef} />
        </div>

        {/* Quick questions */}
        <div className="px-4 py-2 border-t border-border flex gap-2 overflow-x-auto scrollbar-hide">
          {QUICK_QUESTIONS.map((q, i) => (
            <button
              key={i}
              onClick={() => sendMessage(q)}
              className="flex-shrink-0 text-xs px-3 py-1.5 rounded-full bg-muted text-muted-foreground hover:bg-blue-600/10 hover:text-blue-500 border border-border hover:border-blue-500/40 transition-all"
            >
              {q}
            </button>
          ))}
        </div>

        {/* Input */}
        <div className="p-4 border-t border-border flex gap-3">
          <input
            value={input}
            onChange={e => setInput(e.target.value)}
            onKeyDown={e => e.key === 'Enter' && !e.shiftKey && sendMessage(input)}
            placeholder="Posez une question sur vos données..."
            className="input-field flex-1"
          />
          <Button onClick={() => sendMessage(input)} disabled={!input.trim() || loading}>
            {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Send className="w-4 h-4" />}
          </Button>
        </div>
      </div>
    </div>
  )
}
