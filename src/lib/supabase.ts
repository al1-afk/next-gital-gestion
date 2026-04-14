import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://placeholder.supabase.co'
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'placeholder-key'

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
  },
})

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
          user_id: string
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
          user_id: string
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
          user_id: string
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
          user_id: string
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
          user_id: string
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
          user_id: string
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
          type: 'personnel' | 'professionnel'
          date_depense: string
          user_id: string
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
          user_id: string
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
          user_id: string
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
          user_id: string
        }
        Insert: Omit<Database['public']['Tables']['hebergements']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['hebergements']['Insert']>
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
          user_id: string
        }
        Insert: Omit<Database['public']['Tables']['personal_tasks']['Row'], 'id' | 'created_at'>
        Update: Partial<Database['public']['Tables']['personal_tasks']['Insert']>
      }
    }
  }
}
