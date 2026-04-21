/**
 * Centralized entity schemas for Import / Export feature.
 * Each schema describes which columns export, in what order, and how to validate on import.
 */
import type { EntitySchema } from './importExport'

/* ─── Prospects ──────────────────────────────────────────────────── */
export const prospectsSchema: EntitySchema<any> = {
  entity: 'prospect',
  filename: 'prospects',
  fields: [
    { key: 'nom',            label: 'Nom',             required: true },
    { key: 'entreprise',     label: 'Entreprise' },
    { key: 'email',          label: 'Email' },
    { key: 'telephone',      label: 'Téléphone' },
    { key: 'statut',         label: 'Statut',          enum: ['nouveau', 'contacte', 'qualifie', 'proposition', 'gagne', 'perdu'] },
    { key: 'valeur_estimee', label: 'Valeur estimée',  kind: 'number' },
    { key: 'source',         label: 'Source' },
    { key: 'responsable',    label: 'Responsable' },
    { key: 'date_contact',   label: 'Date contact',    kind: 'date' },
    { key: 'date_relance',   label: 'Date relance',    kind: 'date' },
    { key: 'notes',          label: 'Notes' },
  ],
}

/* ─── Clients ────────────────────────────────────────────────────── */
export const clientsSchema: EntitySchema<any> = {
  entity: 'client',
  filename: 'clients',
  fields: [
    { key: 'nom',        label: 'Nom',         required: true },
    { key: 'entreprise', label: 'Entreprise' },
    { key: 'email',      label: 'Email' },
    { key: 'telephone',  label: 'Téléphone' },
    { key: 'adresse',    label: 'Adresse' },
    { key: 'ville',      label: 'Ville' },
    { key: 'pays',       label: 'Pays' },
    { key: 'notes',      label: 'Notes' },
  ],
}

/* ─── Devis ─────────────────────────────────────────────────────── */
export const devisSchema: EntitySchema<any> = {
  entity: 'devis',
  filename: 'devis',
  fields: [
    { key: 'numero',          label: 'Numéro',         required: true },
    { key: 'client_nom',      label: 'Client' },
    { key: 'statut',          label: 'Statut',         enum: ['brouillon', 'envoye', 'accepte', 'refuse', 'expire'] },
    { key: 'date_emission',   label: 'Date émission',  kind: 'date', required: true },
    { key: 'date_expiration', label: 'Date expiration', kind: 'date' },
    { key: 'montant_ht',      label: 'Montant HT',     kind: 'number' },
    { key: 'tva',             label: 'TVA %',          kind: 'number' },
    { key: 'montant_ttc',     label: 'Montant TTC',    kind: 'number' },
    { key: 'notes',           label: 'Notes' },
  ],
}

/* ─── Factures ──────────────────────────────────────────────────── */
export const facturesSchema: EntitySchema<any> = {
  entity: 'facture',
  filename: 'factures',
  fields: [
    { key: 'numero',        label: 'Numéro',         required: true },
    { key: 'client_nom',    label: 'Client' },
    { key: 'statut',        label: 'Statut',         enum: ['brouillon', 'envoyee', 'payee', 'partielle', 'impayee', 'annulee', 'refusee'] },
    { key: 'date_emission', label: 'Date émission',  kind: 'date', required: true },
    { key: 'date_echeance', label: 'Date échéance',  kind: 'date' },
    { key: 'montant_ht',    label: 'Montant HT',     kind: 'number' },
    { key: 'tva',           label: 'TVA %',          kind: 'number' },
    { key: 'montant_ttc',   label: 'Montant TTC',    kind: 'number' },
    { key: 'montant_paye',  label: 'Montant payé',   kind: 'number' },
    { key: 'notes',         label: 'Notes' },
  ],
}

/* ─── Paiements ─────────────────────────────────────────────────── */
export const paiementsSchema: EntitySchema<any> = {
  entity: 'paiement',
  filename: 'paiements',
  fields: [
    { key: 'reference',     label: 'Référence',     required: true },
    { key: 'date',          label: 'Date',          kind: 'date', required: true },
    { key: 'montant',       label: 'Montant',       kind: 'number', required: true },
    { key: 'type_paiement', label: 'Type' },
    { key: 'methode',       label: 'Méthode' },
    { key: 'status',        label: 'Statut' },
    { key: 'notes',         label: 'Notes' },
  ],
}

/* ─── Dépenses ──────────────────────────────────────────────────── */
export const depensesSchema: EntitySchema<any> = {
  entity: 'dépense',
  filename: 'depenses',
  fields: [
    { key: 'date_depense', label: 'Date',        kind: 'date', required: true },
    { key: 'description',  label: 'Description', required: true },
    { key: 'categorie',    label: 'Catégorie' },
    { key: 'type',         label: 'Type',        enum: ['personnel', 'business'] },
    { key: 'montant',      label: 'Montant',     kind: 'number', required: true },
  ],
}

/* ─── Fournisseurs ──────────────────────────────────────────────── */
export const fournisseursSchema: EntitySchema<any> = {
  entity: 'fournisseur',
  filename: 'fournisseurs',
  fields: [
    { key: 'nom',       label: 'Nom',        required: true },
    { key: 'email',     label: 'Email' },
    { key: 'telephone', label: 'Téléphone' },
    { key: 'adresse',   label: 'Adresse' },
    { key: 'categorie', label: 'Catégorie' },
    { key: 'notes',     label: 'Notes' },
  ],
}

/* ─── Domaines ──────────────────────────────────────────────────── */
export const domainesSchema: EntitySchema<any> = {
  entity: 'domaine',
  filename: 'domaines',
  fields: [
    { key: 'nom',                 label: 'Nom de domaine',     required: true },
    { key: 'registrar',           label: 'Registrar' },
    { key: 'date_expiration',     label: 'Date expiration',    kind: 'date' },
    { key: 'prix_renouvellement', label: 'Prix renouvellement', kind: 'number' },
    { key: 'client',              label: 'Client' },
    { key: 'notes',               label: 'Notes' },
  ],
}

/* ─── Hébergements ──────────────────────────────────────────────── */
export const hebergementsSchema: EntitySchema<any> = {
  entity: 'hébergement',
  filename: 'hebergements',
  fields: [
    { key: 'nom',             label: 'Nom',             required: true },
    { key: 'fournisseur',     label: 'Fournisseur' },
    { key: 'type',            label: 'Type' },
    { key: 'date_expiration', label: 'Date expiration', kind: 'date' },
    { key: 'prix_mensuel',    label: 'Prix mensuel',    kind: 'number' },
    { key: 'client',          label: 'Client' },
    { key: 'notes',           label: 'Notes' },
  ],
}

/* ─── Produits ──────────────────────────────────────────────────── */
export const produitsSchema: EntitySchema<any> = {
  entity: 'produit',
  filename: 'produits',
  fields: [
    { key: 'nom',         label: 'Nom',         required: true },
    { key: 'description', label: 'Description' },
    { key: 'type',        label: 'Type',        enum: ['produit', 'service'] },
    { key: 'prix_ht',     label: 'Prix HT',     kind: 'number' },
    { key: 'tva',         label: 'TVA %',       kind: 'number' },
    { key: 'unite',       label: 'Unité' },
  ],
}

/* ─── Contrats ──────────────────────────────────────────────────── */
export const contratsSchema: EntitySchema<any> = {
  entity: 'contrat',
  filename: 'contrats',
  fields: [
    { key: 'numero',     label: 'Numéro',     required: true },
    { key: 'client',     label: 'Client' },
    { key: 'objet',      label: 'Objet' },
    { key: 'montant',    label: 'Montant',    kind: 'number' },
    { key: 'date_debut', label: 'Date début', kind: 'date' },
    { key: 'date_fin',   label: 'Date fin',   kind: 'date' },
    { key: 'statut',     label: 'Statut',     enum: ['actif', 'expire', 'resilie', 'brouillon'] },
  ],
}

/* ─── Bons de commande ──────────────────────────────────────────── */
export const bonsCommandeSchema: EntitySchema<any> = {
  entity: 'bon de commande',
  filename: 'bons_commande',
  fields: [
    { key: 'numero',      label: 'Numéro',      required: true },
    { key: 'fournisseur', label: 'Fournisseur' },
    { key: 'objet',       label: 'Objet' },
    { key: 'montant',     label: 'Montant',     kind: 'number' },
    { key: 'date',        label: 'Date',        kind: 'date' },
    { key: 'statut',      label: 'Statut',      enum: ['envoye', 'recu', 'partiel', 'annule'] },
  ],
}

/* ─── Chèques émis ─────────────────────────────────────────────── */
export const chequesEmisSchema: EntitySchema<any> = {
  entity: 'chèque émis',
  filename: 'cheques_emis',
  fields: [
    { key: 'reference',     label: 'Référence',    required: true },
    { key: 'beneficiaire',  label: 'Bénéficiaire' },
    { key: 'banque',        label: 'Banque' },
    { key: 'montant',       label: 'Montant',      kind: 'number' },
    { key: 'date_emission', label: 'Date émission', kind: 'date' },
    { key: 'statut',        label: 'Statut',       enum: ['emis', 'encaisse', 'refuse', 'annule'] },
  ],
}

/* ─── Chèques reçus ────────────────────────────────────────────── */
export const chequesRecusSchema: EntitySchema<any> = {
  entity: 'chèque reçu',
  filename: 'cheques_recus',
  fields: [
    { key: 'reference',      label: 'Référence',     required: true },
    { key: 'emetteur',       label: 'Émetteur' },
    { key: 'banque',         label: 'Banque' },
    { key: 'montant',        label: 'Montant',       kind: 'number' },
    { key: 'date_reception', label: 'Date réception', kind: 'date' },
    { key: 'date_depot',     label: 'Date dépôt',    kind: 'date' },
    { key: 'statut',         label: 'Statut',        enum: ['recu', 'depose', 'encaisse', 'refuse', 'annule'] },
  ],
}

/* ─── Tâches / Actions ─────────────────────────────────────────── */
export const tachesSchema: EntitySchema<any> = {
  entity: 'tâche',
  filename: 'taches',
  fields: [
    { key: 'titre',           label: 'Titre',           required: true },
    { key: 'description',     label: 'Description' },
    { key: 'statut',          label: 'Statut',          enum: ['todo', 'en_cours', 'done'] },
    { key: 'client',          label: 'Client' },
    { key: 'deal_value',      label: 'Valeur',          kind: 'number' },
    { key: 'revenue_at_risk', label: 'Revenu à risque', kind: 'number' },
    { key: 'deadline',        label: 'Échéance',        kind: 'date' },
    { key: 'categorie',       label: 'Catégorie',       enum: ['suivi', 'proposition', 'livraison', 'support', 'admin', 'relance'] },
    { key: 'stage',           label: 'Stage',           enum: ['prospect', 'actif', 'a_risque', 'gagne', 'perdu'] },
    { key: 'churn_risk',      label: 'Risque churn',    kind: 'number' },
  ],
}

/* ─── Équipe ─────────────────────────────────────────────────── */
export const equipeSchema: EntitySchema<any> = {
  entity: 'membre',
  filename: 'equipe',
  fields: [
    { key: 'nom',           label: 'Nom',          required: true },
    { key: 'prenom',        label: 'Prénom',       required: true },
    { key: 'email',         label: 'Email' },
    { key: 'telephone',     label: 'Téléphone' },
    { key: 'poste',         label: 'Poste' },
    { key: 'departement',   label: 'Département' },
    { key: 'role',          label: 'Rôle',         enum: ['admin', 'manager', 'commercial', 'comptable', 'viewer'] },
    { key: 'salaire_base',  label: 'Salaire base', kind: 'number' },
    { key: 'date_embauche', label: 'Embauche',     kind: 'date' },
    { key: 'statut',        label: 'Statut',       enum: ['actif', 'inactif', 'conge'] },
  ],
}

/* ─── Abonnements (charges) ─────────────────────────────────────── */
export const abonnementsSchema: EntitySchema<any> = {
  entity: 'abonnement',
  filename: 'abonnements',
  fields: [
    { key: 'nom',                 label: 'Nom',          required: true },
    { key: 'fournisseur',         label: 'Fournisseur' },
    { key: 'categorie',           label: 'Catégorie' },
    { key: 'montant',             label: 'Montant',      kind: 'number' },
    { key: 'cycle',               label: 'Cycle',        enum: ['mensuel', 'trimestriel', 'annuel'] },
    { key: 'date_renouvellement', label: 'Renouvellement', kind: 'date' },
    { key: 'statut',              label: 'Statut',       enum: ['actif', 'inactif', 'annule'] },
  ],
}

/* ─── Abonnements clients (MRR) ─────────────────────────────────── */
export const abonnementsClientsSchema: EntitySchema<any> = {
  entity: 'abonnement client',
  filename: 'abonnements_clients',
  fields: [
    { key: 'nom',                        label: 'Nom',                 required: true },
    { key: 'client_nom',                 label: 'Client',              required: true },
    { key: 'montant',                    label: 'Montant',             kind: 'number' },
    { key: 'cycle',                      label: 'Cycle',               enum: ['mensuel', 'trimestriel', 'annuel'] },
    { key: 'date_debut',                 label: 'Date début',          kind: 'date' },
    { key: 'date_prochaine_facturation', label: 'Prochaine facturation', kind: 'date' },
    { key: 'statut',                     label: 'Statut',              enum: ['actif', 'pause', 'annule', 'impaye'] },
    { key: 'facture_auto',               label: 'Facturation auto',    kind: 'boolean' },
  ],
}
