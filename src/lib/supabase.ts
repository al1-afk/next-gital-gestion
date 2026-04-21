import { createClient } from '@supabase/supabase-js'

const supabaseUrl     = import.meta.env.VITE_SUPABASE_URL     || 'https://placeholder.supabase.co'
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'placeholder-key'

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession:   true,
    autoRefreshToken: true,
  },
})

/* ─── Tenant-scoped query helper ─────────────────────────────────────
   Usage:
     const db = tenantDb(tenantId)
     db.from('clients').select('*')        // always filtered to tenant
     db.rpc('my_fn', { ... })              // passes tenant header
   The tenant_id is carried via a custom Postgres header which the
   current_tenant_id() SQL function reads from request.jwt.claims.
   For RLS to work the JWT must also carry app_metadata.tenant_id
   (set by the auth.set_tenant_claim trigger in the migration).
──────────────────────────────────────────────────────────────────── */
export function tenantDb(tenantId: string) {
  return createClient(supabaseUrl, supabaseAnonKey, {
    auth: {
      persistSession:   false,
      autoRefreshToken: false,
    },
    global: {
      headers: {
        'x-tenant-id': tenantId,
      },
    },
  })
}

export type Database = {
  public: {
    Tables: {
      prospects: {
        Row: {
          id: string
          created_at: string
          nom: string
          email: string | null
          telephone: string | null
          entreprise: string | null
          statut: string
          valeur_estimee: number | null
          source: string | null
          notes: string | null
          responsable: string | null
          date_contact: string | null
          date_relance: string | null
          tenant_id: string
        }
        Insert: Omit<Database['public']['Tables']['prospects']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['prospects']['Insert']>
      }
      clients: {
        Row: {
          id: string
          created_at: string
          nom: string
          email: string | null
          telephone: string | null
          entreprise: string | null
          adresse: string | null
          ville: string | null
          pays: string | null
          notes: string | null
          tenant_id: string
        }
        Insert: Omit<Database['public']['Tables']['clients']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['clients']['Insert']>
      }
      devis: {
        Row: {
          id: string
          created_at: string
          numero: string
          client_id: string | null
          statut: 'brouillon' | 'envoye' | 'accepte' | 'refuse' | 'expire'
          date_emission: string
          date_expiration: string | null
          montant_ht: number
          tva: number
          montant_ttc: number
          notes: string | null
          tenant_id: string
        }
        Insert: Omit<Database['public']['Tables']['devis']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['devis']['Insert']>
      }
      factures: {
        Row: {
          id: string
          created_at: string
          numero: string
          client_id: string | null
          statut: 'impayee' | 'partielle' | 'payee' | 'annulee'
          date_emission: string
          date_echeance: string | null
          montant_ht: number
          tva: number
          montant_ttc: number
          montant_paye: number
          notes: string | null
          tenant_id: string
        }
        Insert: Omit<Database['public']['Tables']['factures']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['factures']['Insert']>
      }
      paiements: {
        Row: {
          id: string
          created_at: string
          facture_id: string | null
          montant: number
          mode_paiement: 'virement' | 'especes' | 'cheque' | 'carte' | 'autre'
          date_paiement: string
          reference: string | null
          notes: string | null
          tenant_id: string
        }
        Insert: Omit<Database['public']['Tables']['paiements']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['paiements']['Insert']>
      }
      team_members: {
        Row: {
          id: string
          created_at: string
          nom: string
          prenom: string
          email: string | null
          telephone: string | null
          poste: string | null
          departement: string | null
          salaire_base: number
          date_embauche: string | null
          statut: 'actif' | 'inactif' | 'conge'
          tenant_id: string
        }
        Insert: Omit<Database['public']['Tables']['team_members']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['team_members']['Insert']>
      }
      depenses: {
        Row: {
          id: string
          created_at: string
          description: string
          montant: number
          categorie: string
          type: 'personnel' | 'business'
          date_depense: string
          tenant_id: string
        }
        Insert: Omit<Database['public']['Tables']['depenses']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['depenses']['Insert']>
      }
      fournisseurs: {
        Row: {
          id: string
          created_at: string
          nom: string
          email: string | null
          telephone: string | null
          adresse: string | null
          categorie: string | null
          notes: string | null
          tenant_id: string
        }
        Insert: Omit<Database['public']['Tables']['fournisseurs']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['fournisseurs']['Insert']>
      }
      domaines: {
        Row: {
          id: string
          created_at: string
          nom: string
          registrar: string | null
          date_expiration: string
          prix_renouvellement: number | null
          client_id: string | null
          notes: string | null
          tenant_id: string
        }
        Insert: Omit<Database['public']['Tables']['domaines']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['domaines']['Insert']>
      }
      hebergements: {
        Row: {
          id: string
          created_at: string
          nom: string
          fournisseur: string | null
          date_expiration: string
          prix_mensuel: number | null
          client_id: string | null
          notes: string | null
          tenant_id: string
        }
        Insert: Omit<Database['public']['Tables']['hebergements']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['hebergements']['Insert']>
      }
      automation_rules: {
        Row: {
          id: string
          created_at: string
          tenant_id: string
          label: string
          description: string
          enabled: boolean
          trigger_type: string
          trigger_config: Record<string, unknown>
          conditions: unknown[]
          actions: unknown[]
          runs_total: number
          last_run_at: string | null
        }
        Insert: Omit<Database['public']['Tables']['automation_rules']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['automation_rules']['Insert']>
      }
      automation_logs: {
        Row: {
          id: string
          created_at: string
          rule_id: string | null
          tenant_id: string
          trigger_ref: string | null
          trigger_table: string | null
          action_type: string
          action_result: Record<string, unknown> | null
          status: 'pending' | 'success' | 'failed'
          error_message: string | null
          executed_at: string
        }
        Insert: Omit<Database['public']['Tables']['automation_logs']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['automation_logs']['Insert']>
      }
      alerts: {
        Row: {
          id: string
          created_at: string
          tenant_id: string
          type: string
          priority: 'low' | 'medium' | 'critical'
          title: string
          message: string | null
          entity_id: string | null
          entity_type: string | null
          is_read: boolean
          is_resolved: boolean
        }
        Insert: Omit<Database['public']['Tables']['alerts']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['alerts']['Insert']>
      }
      client_subscriptions: {
        Row: {
          id: string
          created_at: string
          tenant_id: string
          client_id: string | null
          nom: string
          montant: number
          cycle: 'mensuel' | 'trimestriel' | 'annuel'
          montant_mensuel: number
          date_debut: string
          date_prochaine_facturation: string
          statut: 'actif' | 'pause' | 'annule' | 'impaye'
          date_annulation: string | null
          annulation_raison: string | null
          facture_auto: boolean
        }
        Insert: Omit<Database['public']['Tables']['client_subscriptions']['Row'], 'id' | 'created_at' | 'montant_mensuel'>
        Update: Partial<Database['public']['Tables']['client_subscriptions']['Insert']>
      }
      workspace_members: {
        Row: {
          id: string
          created_at: string
          workspace_id: string
          member_email: string
          member_id: string | null
          role: 'admin' | 'manager' | 'commercial' | 'comptable' | 'viewer'
          permissions: Record<string, unknown>
          invited_at: string
          accepted_at: string | null
          status: 'pending' | 'active' | 'revoked'
        }
        Insert: Omit<Database['public']['Tables']['workspace_members']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['workspace_members']['Insert']>
      }
      personal_tasks: {
        Row: {
          id: string
          created_at: string
          titre: string
          description: string | null
          statut: 'todo' | 'en_cours' | 'done'
          priorite: 'urgent_important' | 'important' | 'urgent' | 'low'
          date_echeance: string | null
          client_id: string | null
          tenant_id: string
        }
        Insert: Omit<Database['public']['Tables']['personal_tasks']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['personal_tasks']['Insert']>
      }
    }
  }
}
