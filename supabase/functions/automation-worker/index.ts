/**
 * automation-worker — Supabase Edge Function (Deno)
 *
 * Scheduled via Supabase cron (pg_cron) every hour:
 *   SELECT cron.schedule('automation-worker', '0 * * * *',
 *     $$SELECT net.http_post(url:='<FUNCTION_URL>', headers:='{"Authorization":"Bearer <ANON_KEY>"}')$$);
 *
 * What it does:
 *  1. Fetches all enabled automation rules
 *  2. Evaluates trigger conditions against live data
 *  3. Executes qualifying actions (create alert, send email placeholder, create task)
 *  4. Writes execution log entries
 *  5. Calls generate_system_alerts() for each active user
 */

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabaseUrl     = Deno.env.get('SUPABASE_URL')!
const supabaseService = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const supabase = createClient(supabaseUrl, supabaseService, {
  auth: { persistSession: false },
})

// ── Types ─────────────────────────────────────────────────────────
interface AutomationRule {
  id:             string
  user_id:        string
  label:          string
  enabled:        boolean
  trigger_type:   TriggerType
  trigger_config: Record<string, unknown>
  conditions:     Condition[]
  actions:        AutoAction[]
  runs_total:     number
}

type TriggerType =
  | 'invoice_overdue'
  | 'quote_accepted'
  | 'subscription_expiring'
  | 'prospect_idle'
  | 'domain_expiring'
  | 'payment_received'

interface Condition {
  field:    string
  operator: 'gt' | 'lt' | 'eq' | 'gte' | 'lte' | 'contains'
  value:    unknown
}

interface AutoAction {
  type:   'create_alert' | 'create_task' | 'send_email' | 'update_status'
  config: Record<string, unknown>
}

// ── Condition evaluator ───────────────────────────────────────────
function evaluate(conditions: Condition[], ctx: Record<string, unknown>): boolean {
  return conditions.every(c => {
    const val = ctx[c.field]
    switch (c.operator) {
      case 'gt':       return Number(val) >  Number(c.value)
      case 'lt':       return Number(val) <  Number(c.value)
      case 'gte':      return Number(val) >= Number(c.value)
      case 'lte':      return Number(val) <= Number(c.value)
      case 'eq':       return val === c.value
      case 'contains': return String(val).toLowerCase().includes(String(c.value).toLowerCase())
      default:         return true
    }
  })
}

// ── Action executor ───────────────────────────────────────────────
async function executeAction(
  action:  AutoAction,
  rule:    AutomationRule,
  ctx:     Record<string, unknown>,
): Promise<{ success: boolean; result: Record<string, unknown>; error?: string }> {
  try {
    switch (action.type) {

      case 'create_alert': {
        const priority = (action.config.priority as string) || 'medium'
        const title    = interpolate(action.config.title as string || rule.label, ctx)
        const message  = interpolate(action.config.message as string || '', ctx)
        const { error } = await supabase.from('alerts').insert({
          user_id:     rule.user_id,
          type:        rule.trigger_type,
          priority,
          title,
          message,
          entity_id:   ctx.entity_id as string || null,
          entity_type: ctx.entity_type as string || null,
          is_read:     false,
          is_resolved: false,
        })
        if (error) throw new Error(error.message)
        return { success: true, result: { title, priority } }
      }

      case 'create_task': {
        const titre = interpolate(action.config.titre as string || rule.label, ctx)
        const { error } = await supabase.from('personal_tasks').insert({
          user_id:       rule.user_id,
          titre,
          description:   interpolate(action.config.description as string || '', ctx),
          statut:        'todo',
          priorite:      (action.config.priorite as string) || 'urgent_important',
          date_echeance: action.config.date_echeance as string || null,
          client_id:     ctx.client_id as string || null,
        })
        if (error) throw new Error(error.message)
        return { success: true, result: { titre } }
      }

      case 'send_email': {
        // Placeholder — wire to Resend / SendGrid in production
        console.log(`[send_email] To: ${action.config.to} Subject: ${action.config.subject}`)
        return { success: true, result: { queued: true, to: action.config.to } }
      }

      case 'update_status': {
        const table = action.config.table as string
        const id    = ctx.entity_id as string
        if (!table || !id) throw new Error('update_status requires table + entity_id in context')
        const { error } = await supabase
          .from(table)
          .update({ statut: action.config.statut })
          .eq('id', id)
          .eq('user_id', rule.user_id)
        if (error) throw new Error(error.message)
        return { success: true, result: { table, id, statut: action.config.statut } }
      }

      default:
        return { success: false, result: {}, error: `Unknown action type: ${action.type}` }
    }
  } catch (err) {
    return { success: false, result: {}, error: String(err) }
  }
}

function interpolate(template: string, ctx: Record<string, unknown>): string {
  return template.replace(/\{\{(\w+)\}\}/g, (_, key) => String(ctx[key] ?? ''))
}

// ── Trigger evaluators ────────────────────────────────────────────
async function getTriggeredContexts(
  rule: AutomationRule,
): Promise<Record<string, unknown>[]> {
  const cfg = rule.trigger_config
  const uid = rule.user_id

  switch (rule.trigger_type) {

    case 'invoice_overdue': {
      const minDays = Number(cfg.min_days_overdue ?? 7)
      const cutoff  = new Date()
      cutoff.setDate(cutoff.getDate() - minDays)
      const { data } = await supabase
        .from('factures')
        .select('id, numero, montant_ttc, montant_paye, date_echeance, client_id')
        .eq('user_id', uid)
        .in('statut', ['impayee', 'partielle'])
        .lt('date_echeance', cutoff.toISOString().slice(0, 10))
        .not('date_echeance', 'is', null)
      return (data ?? []).map(f => ({
        entity_id:    f.id,
        entity_type:  'facture',
        client_id:    f.client_id,
        numero:       f.numero,
        remaining:    f.montant_ttc - f.montant_paye,
        days_overdue: Math.floor((Date.now() - new Date(f.date_echeance).getTime()) / 86_400_000),
      }))
    }

    case 'quote_accepted': {
      const { data } = await supabase
        .from('devis')
        .select('id, numero, montant_ttc, client_id, created_at')
        .eq('user_id', uid)
        .eq('statut', 'accepte')
      return (data ?? []).map(d => ({
        entity_id:   d.id,
        entity_type: 'devis',
        client_id:   d.client_id,
        numero:      d.numero,
        montant:     d.montant_ttc,
      }))
    }

    case 'subscription_expiring': {
      const daysAhead = Number(cfg.days_ahead ?? 7)
      const cutoff    = new Date()
      cutoff.setDate(cutoff.getDate() + daysAhead)
      const { data } = await supabase
        .from('client_subscriptions')
        .select('id, nom, date_prochaine_facturation, montant_mensuel, client_id')
        .eq('user_id', uid)
        .eq('statut', 'actif')
        .lte('date_prochaine_facturation', cutoff.toISOString().slice(0, 10))
        .gte('date_prochaine_facturation', new Date().toISOString().slice(0, 10))
      return (data ?? []).map(s => ({
        entity_id:   s.id,
        entity_type: 'subscription',
        client_id:   s.client_id,
        nom:         s.nom,
        date:        s.date_prochaine_facturation,
        montant:     s.montant_mensuel,
      }))
    }

    case 'prospect_idle': {
      const idleDays = Number(cfg.idle_days ?? 14)
      const cutoff   = new Date()
      cutoff.setDate(cutoff.getDate() - idleDays)
      const { data } = await supabase
        .from('prospects')
        .select('id, nom, statut, valeur_estimee, date_contact')
        .eq('user_id', uid)
        .not('statut', 'in', '(gagne,perdu)')
        .lt('date_contact', cutoff.toISOString().slice(0, 10))
      return (data ?? []).map(p => ({
        entity_id:   p.id,
        entity_type: 'prospect',
        nom:         p.nom,
        statut:      p.statut,
        valeur:      p.valeur_estimee,
        idle_days:   Math.floor((Date.now() - new Date(p.date_contact).getTime()) / 86_400_000),
      }))
    }

    case 'domain_expiring': {
      const daysAhead = Number(cfg.days_ahead ?? 30)
      const cutoff    = new Date()
      cutoff.setDate(cutoff.getDate() + daysAhead)
      const { data } = await supabase
        .from('domaines')
        .select('id, nom, date_expiration, client_id')
        .eq('user_id', uid)
        .lte('date_expiration', cutoff.toISOString().slice(0, 10))
        .gte('date_expiration', new Date().toISOString().slice(0, 10))
      return (data ?? []).map(d => ({
        entity_id:   d.id,
        entity_type: 'domaine',
        client_id:   d.client_id,
        nom:         d.nom,
        date:        d.date_expiration,
        days_left:   Math.floor((new Date(d.date_expiration).getTime() - Date.now()) / 86_400_000),
      }))
    }

    default:
      return []
  }
}

// ── Main handler ──────────────────────────────────────────────────
Deno.serve(async (_req) => {
  const startedAt = Date.now()
  let totalRules  = 0
  let totalFired  = 0
  let totalErrors = 0

  try {
    // 1. Fetch all enabled rules
    const { data: rules, error: rulesError } = await supabase
      .from('automation_rules')
      .select('*')
      .eq('enabled', true)

    if (rulesError) throw new Error(rulesError.message)
    totalRules = rules?.length ?? 0

    // 2. Collect unique user_ids for system alert generation
    const userIds = [...new Set((rules ?? []).map(r => r.user_id))]

    // 3. Generate system alerts for each user
    for (const uid of userIds) {
      await supabase.rpc('generate_system_alerts', { p_user_id: uid })
    }

    // 4. Process automation rules
    for (const rule of (rules ?? []) as AutomationRule[]) {
      const contexts = await getTriggeredContexts(rule)

      for (const ctx of contexts) {
        if (!evaluate(rule.conditions, ctx)) continue

        // Execute each action
        for (const action of rule.actions) {
          const result = await executeAction(action, rule, ctx)
          totalFired++

          // Log execution
          await supabase.from('automation_logs').insert({
            rule_id:       rule.id,
            user_id:       rule.user_id,
            trigger_ref:   ctx.entity_id as string || null,
            trigger_table: ctx.entity_type as string || null,
            action_type:   action.type,
            action_result: result.result,
            status:        result.success ? 'success' : 'failed',
            error_message: result.error || null,
            executed_at:   new Date().toISOString(),
          })

          if (!result.success) totalErrors++
        }
      }

      // Update rule run counter
      await supabase
        .from('automation_rules')
        .update({ runs_total: rule.runs_total + contexts.length, last_run_at: new Date().toISOString() })
        .eq('id', rule.id)
    }

    const elapsed = Date.now() - startedAt
    const summary = { ok: true, totalRules, totalFired, totalErrors, elapsedMs: elapsed }
    console.log('[automation-worker]', summary)

    return new Response(JSON.stringify(summary), {
      status:  200,
      headers: { 'Content-Type': 'application/json' },
    })

  } catch (err) {
    console.error('[automation-worker] fatal error:', err)
    return new Response(JSON.stringify({ ok: false, error: String(err) }), {
      status:  500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
