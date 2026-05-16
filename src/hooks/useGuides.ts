/* ─────────────────────────────────────────────────────────────────
   useGuides — hooks pour le module "Guides" (playbook Next Gital)

   Sept tables couvertes :
     - guide_steps                (6 étapes par tenant)
     - guide_templates            (messages copiables)
     - guide_checklists           (items à cocher)
     - guide_checklist_state      (état coché par user)
     - guide_template_renders     (historique d'usage)
     - guide_discovery_questions  (formulaire 8Q)
     - tenant_vision              (Primary Aim, admin-only)

   Conventions :
     - queryKey scopé par tenant via currentTenantIdForCache()
     - Cache invalidation sur mutations
     - Pas de tenant_id dans le body de create (serveur l'écrase)
───────────────────────────────────────────────────────────────── */

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  guideStepsApi,
  guideTemplatesApi,
  guideChecklistsApi,
  guideChecklistStateApi,
  guideTemplateRendersApi,
  guideDiscoveryQuestionsApi,
  tenantVisionApi,
} from '@/lib/api'
import { currentTenantIdForCache, currentUserId } from '@/lib/authToken'
import { toast } from 'sonner'

/* ── Types ───────────────────────────────────────────────────── */

export interface GuideStep {
  id:           string
  tenant_id:    string
  step_number:  number
  step_key:     string
  title:        string
  subtitle:     string | null
  icon:         string | null
  timer_label:  string | null
  color_hex:    string
  content_md:   string | null
  created_at:   string
  updated_at:   string
}

export interface GuideTemplate {
  id:            string
  tenant_id:     string
  step_id:       string | null
  template_key:  string
  channel:       'whatsapp' | 'email' | 'sms' | 'general' | 'instagram'
  label:         string
  content:       string
  variables:     string[]
  ordre:         number
  created_at:    string
  updated_at:    string
}

export interface GuideChecklist {
  id:           string
  tenant_id:    string
  step_id:      string | null
  item_order:   number
  item_text:    string
  is_one_time:  boolean
  created_at:   string
}

export interface GuideChecklistState {
  id:                  string
  tenant_id:           string
  user_id:             string
  checklist_item_id:   string
  is_checked:          boolean
  checked_at:          string | null
}

export interface GuideTemplateRender {
  id:                string
  tenant_id:         string
  user_id:           string | null
  client_id:         string | null
  prospect_id:       string | null
  template_id:       string | null
  channel:           string | null
  rendered_content:  string
  created_at:        string
}

export interface GuideDiscoveryQuestion {
  id:              string
  tenant_id:       string
  question_order:  number
  question_text:   string
  question_why:    string | null
  input_type:      'text' | 'select' | 'textarea' | 'budget_range' | 'multi' | 'number' | 'date'
  options:         string[]
  is_required:     boolean
  created_at:      string
}

export interface TenantVision {
  id:                       string
  tenant_id:                string
  primary_aim:              string | null
  lifestyle_target:         string | null
  why_statement:            string | null
  monthly_revenue_cap:      number | null
  max_hours_week:           number | null
  strategic_objective:      string | null
  monthly_target:           number | null
  monthly_target_projets:   number | null
  target_conversion_rate:   number | null
  target_workspaces:        number | null
  target_avis_google:       number | null
  created_at:               string
  updated_at:               string
}

/* ── Helpers ─────────────────────────────────────────────────── */
const tk = (key: string) => [key, currentTenantIdForCache()] as const

/* ── guide_steps ─────────────────────────────────────────────── */
export function useGuideSteps() {
  return useQuery<GuideStep[]>({
    queryKey: tk('guide_steps'),
    queryFn:  () => guideStepsApi.list({ orderBy: 'step_number', order: 'asc', limit: 50 }) as Promise<GuideStep[]>,
    staleTime: 1000 * 60 * 10,
  })
}

/* ── guide_templates ─────────────────────────────────────────── */
export function useGuideTemplates() {
  return useQuery<GuideTemplate[]>({
    queryKey: tk('guide_templates'),
    queryFn:  () => guideTemplatesApi.list({ orderBy: 'ordre', order: 'asc', limit: 500 }) as Promise<GuideTemplate[]>,
    staleTime: 1000 * 60 * 10,
  })
}

/* ── guide_checklists ────────────────────────────────────────── */
export function useGuideChecklists() {
  return useQuery<GuideChecklist[]>({
    queryKey: tk('guide_checklists'),
    queryFn:  () => guideChecklistsApi.list({ orderBy: 'item_order', order: 'asc', limit: 500 }) as Promise<GuideChecklist[]>,
    staleTime: 1000 * 60 * 10,
  })
}

/* ── guide_checklist_state ───────────────────────────────────── */
export function useGuideChecklistState() {
  return useQuery<GuideChecklistState[]>({
    queryKey: tk('guide_checklist_state'),
    queryFn:  () => guideChecklistStateApi.list({ orderBy: 'checked_at', order: 'desc', limit: 1000 }) as Promise<GuideChecklistState[]>,
    staleTime: 1000 * 30,
  })
}

/** Toggle ON/OFF un item de checklist pour l'utilisateur courant.
 *  Crée la ligne si elle n'existe pas, sinon met à jour. */
export function useToggleChecklistItem() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async ({ checklist_item_id, existing }: {
      checklist_item_id: string
      existing?: GuideChecklistState
    }) => {
      if (existing) {
        const next = !existing.is_checked
        return guideChecklistStateApi.update(existing.id, {
          is_checked: next,
          checked_at: next ? new Date().toISOString() : null,
        } as any) as Promise<GuideChecklistState>
      }
      const userId = currentUserId()
      if (!userId) throw new Error('Non authentifié')
      return guideChecklistStateApi.create({
        user_id:          userId,
        checklist_item_id,
        is_checked:       true,
        checked_at:       new Date().toISOString(),
      } as any) as Promise<GuideChecklistState>
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['guide_checklist_state'] })
    },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/* ── guide_template_renders ──────────────────────────────────── */
export function useGuideTemplateRenders() {
  return useQuery<GuideTemplateRender[]>({
    queryKey: tk('guide_template_renders'),
    queryFn:  () => guideTemplateRendersApi.list({ orderBy: 'created_at', order: 'desc', limit: 100 }) as Promise<GuideTemplateRender[]>,
    staleTime: 1000 * 30,
  })
}

export function useLogTemplateRender() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: {
      template_id?: string | null
      client_id?:   string | null
      prospect_id?: string | null
      channel?:     string | null
      rendered_content: string
    }) => {
      const userId = currentUserId()
      return guideTemplateRendersApi.create({
        ...data,
        user_id: userId ?? null,
      } as any) as Promise<GuideTemplateRender>
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['guide_template_renders'] }),
    onError: () => {}, // silencieux : c'est un log, pas critique
  })
}

/* ── guide_discovery_questions ───────────────────────────────── */
export function useDiscoveryQuestions() {
  return useQuery<GuideDiscoveryQuestion[]>({
    queryKey: tk('guide_discovery_questions'),
    queryFn:  () => guideDiscoveryQuestionsApi.list({ orderBy: 'question_order', order: 'asc', limit: 50 }) as Promise<GuideDiscoveryQuestion[]>,
    staleTime: 1000 * 60 * 10,
  })
}

/* ── tenant_vision ───────────────────────────────────────────── */
export function useTenantVision() {
  return useQuery<TenantVision | null>({
    queryKey: tk('tenant_vision'),
    queryFn:  async () => {
      const list = await tenantVisionApi.list({ limit: 1 }) as TenantVision[]
      return list[0] ?? null
    },
    staleTime: 1000 * 60 * 5,
  })
}

export function useUpdateTenantVision() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async ({ id, ...data }: Partial<TenantVision> & { id?: string }) => {
      if (id) {
        return tenantVisionApi.update(id, data) as Promise<TenantVision>
      }
      return tenantVisionApi.create(data as any) as Promise<TenantVision>
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['tenant_vision'] })
      toast.success('Vision mise à jour')
    },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/* ── Rendu de template (remplace [Variable] par les valeurs) ──
   Utilitaire pur — pas un hook. */
export function renderTemplate(content: string, vars: Record<string, string>): string {
  let out = content
  for (const [k, v] of Object.entries(vars)) {
    // Remplace [Variable] sans regex spéciaux (safe)
    const needle = `[${k}]`
    out = out.split(needle).join(v ?? '')
  }
  return out
}
