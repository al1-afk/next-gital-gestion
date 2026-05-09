export type AccountType = 'personal' | 'company'

export const ACCOUNT_LABELS: Record<AccountType, string> = {
  personal: 'Compte personnel',
  company:  'Compte société',
}

export type TxType = 'income' | 'expense'

export type Category =
  | 'cash_withdrawal'
  | 'freelance'
  | 'advertising'
  | 'hosting'
  | 'saas_tool'
  | 'salary'
  | 'invoice_paid'
  | 'client_revenue'
  | 'fixed_charge'
  | 'card_topup'
  | 'bank_fee'
  | 'transfer'
  | 'other'

export interface BankTransaction {
  id: string
  date: string          // ISO yyyy-mm-dd
  label: string
  amount: number        // signed: + income, - expense
  type: TxType
  category: Category
  client_id?: string
  project_id?: string
  source_pdf?: string
  ai_confidence: number // 0..1
  manual_override?: boolean
}

export const CATEGORY_LABELS: Record<Category, string> = {
  cash_withdrawal: 'Retrait cash',
  freelance:       'Freelance',
  advertising:     'Publicité',
  hosting:         'Hébergement & domaines',
  saas_tool:       'Outils SaaS',
  salary:          'Salaires',
  invoice_paid:    'Facture payée',
  client_revenue:  'Revenu client',
  fixed_charge:    'Charges fixes',
  card_topup:      'Recharge carte',
  bank_fee:        'Frais bancaires',
  transfer:        'Virement',
  other:           'Autre',
}

export const CATEGORY_COLORS: Record<Category, string> = {
  cash_withdrawal: '#f59e0b',
  freelance:       '#8b5cf6',
  advertising:     '#ec4899',
  hosting:         '#06b6d4',
  saas_tool:       '#0ea5e9',
  salary:          '#6366f1',
  invoice_paid:    '#10b981',
  client_revenue:  '#22c55e',
  fixed_charge:    '#64748b',
  card_topup:      '#f97316',
  bank_fee:        '#ef4444',
  transfer:        '#94a3b8',
  other:           '#475569',
}
