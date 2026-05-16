# Prompt pour Claude — Module Gestion des Stagiaires (NEXT GITAL SARL AU)

## 🎯 Objectif

Créer dans l'application existante un module complet **"Stagiaires"** permettant à NEXT GITAL SARL AU de :

1. **Gérer une base de données des stagiaires** (CRUD complet).
2. **Générer automatiquement 3 documents officiels** à partir des informations saisies :
   - **Attestation d'acceptation de stage** (avant le début du stage)
   - **Convention de stage** (contrat signé entre les parties)
   - **Attestation de stage** (délivrée à la fin du stage)

L'utilisateur ne doit avoir qu'à saisir les informations du stagiaire **une seule fois**, puis cliquer sur un bouton pour générer chacun des trois documents en PDF (téléchargeable et imprimable).

---

## 🧱 Stack technique du projet

- **Frontend** : React + TypeScript + Vite + TailwindCSS
- **Backend** : Supabase (PostgreSQL + Auth + Storage)
- **Routing** : React Router
- **PDF** : utiliser `jspdf` + `jspdf-autotable` OU `react-pdf` (cohérent avec le reste de l'app — vérifier dans `package.json`)
- **Structure** : suivre exactement le pattern des pages existantes (ex. `Contrats.tsx`, `Devis.tsx`, `Clients.tsx`)
- **Multi-tenant** : respecter l'architecture tenant existante (voir `ARCHITECTURE_TENANT.md`)

---

## 📋 Informations à collecter pour chaque stagiaire

Créer une table Supabase `stagiaires` avec les colonnes suivantes :

| Champ | Type | Obligatoire | Notes |
|---|---|---|---|
| `id` | uuid (PK) | ✅ | auto |
| `tenant_id` | uuid (FK) | ✅ | multi-tenant |
| `nom_complet` | text | ✅ | Nom et prénom |
| `genre` | enum('homme','femme') | ✅ | pour "M./Mme", "il/elle", "stagiaire/la stagiaire" |
| `telephone` | text | ✅ | format marocain |
| `email` | text | ✅ | validation email |
| `cin` | text | ✅ | Carte Nationale (ex: F766383) |
| `adresse` | text | ✅ | adresse de résidence complète |
| `date_naissance` | date | ⬜ | utilisée dans la convention |
| `lieu_naissance` | text | ⬜ | utilisé dans la convention |
| `etablissement` | text | ✅ | établissement / école d'envoi |
| `formation` | text | ⬜ | nature de la formation (défaut: "Marketing digital / Création de site internet") |
| `date_debut` | date | ✅ | début du stage |
| `date_fin` | date | ✅ | fin du stage |
| `departement` | text | ⬜ | département d'accueil (défaut: "création de sites web et référencement naturel (SEO)") |
| `statut` | enum('accepte','en_cours','termine','annule') | ✅ | état du stagiaire |
| `created_at` | timestamptz | ✅ | auto |
| `updated_at` | timestamptz | ✅ | auto |

Ajouter les RLS policies Supabase pour isolation par `tenant_id`.

---

## 🖥️ Interface utilisateur

### Page `Stagiaires.tsx`

- **Liste** : tableau avec colonnes `Nom complet | CIN | Établissement | Période | Statut | Actions`
- **Filtres** : par statut, par établissement, par période
- **Recherche** : par nom, CIN, email
- **Bouton "+ Nouveau stagiaire"** : ouvre un modal/page formulaire
- **Actions par ligne** :
  - 👁️ Voir détails
  - ✏️ Modifier
  - 🗑️ Supprimer (avec confirmation)
  - 📄 **Générer Attestation d'acceptation** (bouton bleu)
  - 📄 **Générer Convention de stage** (bouton vert)
  - 📄 **Générer Attestation de fin de stage** (bouton orange) — visible uniquement si `statut = 'termine'` ou date_fin passée

### Formulaire stagiaire

- Sections groupées : **Identité** | **Coordonnées** | **Formation & Stage**
- Validation côté client (Zod ou équivalent existant dans le projet)
- Date_fin > Date_debut obligatoirement

### Page détails (optionnel mais recommandé)

- Vue récap complète + boutons de génération des 3 PDFs

---

## 📄 Génération des PDF — Templates EXACTS à respecter

Les 3 documents doivent reproduire **fidèlement** la mise en forme ci-dessous. Utiliser les placeholders `{{...}}` qui seront remplacés dynamiquement par les données du stagiaire.

### Données de l'entreprise (constantes — à mettre dans `src/lib/entreprise.ts`)

```ts
export const ENTREPRISE = {
  raisonSociale: "NEXT GITAL SARL AU",
  activite: "Marketing Digital & Développement Web",
  adresse: "Rue Mohamed V Immeuble Kissi, 4ème étage Bureau N°7 Oujda",
  telephone: "0620002066",
  gerant: "Ibrahim Messouali",
  ville: "Oujda",
};
```

---

### 📄 Document 1 — ATTESTATION D'ACCEPTATION DE STAGE

```
NEXT GITAL SARL AU
Marketing Digital & Développement Web
Rue Mohamed V Immeuble Kissi, 4ème étage Bureau N°7 Oujda


                    ATTESTATION D'ACCEPTATION DE STAGE


Je soussigné, Ibrahim Messouali, gérant de la société NEXTGITAL SARL AU,
atteste par la présente que :

{{civilite}} {{nom_complet}}

est {{accepte_e}} en tant que {{stagiaire_e}} au sein de notre entreprise.

Le stage se déroulera du {{date_debut}} au {{date_fin}},
et portera sur les activités liées au développement web et marketing digital.

Cette attestation est délivrée à l'intéressé{{e_accord}} pour servir et valoir
ce que de droit.

Fait à Oujda, le {{date_emission}}
```

**Règles de remplacement :**
- `{{civilite}}` → `M.` si homme, `Mme` si femme
- `{{accepte_e}}` → `accepté` (homme) / `acceptée` (femme)
- `{{stagiaire_e}}` → `stagiaire`
- `{{e_accord}}` → `` (vide pour homme) / `e` (pour femme)
- `{{date_debut}}` / `{{date_fin}}` → format `JJ/MM/AAAA`
- `{{date_emission}}` → date du jour, format `JJ/MM/AAAA`

---

### 📄 Document 2 — CONVENTION DE STAGE

```
                          CONVENTION DE STAGE


ENTREPRISE D'ACCUEIL

Nom : NEXT GITAL
Représentée par : Ibrahim Messouali
Adresse : Rue Mohammed V, Immeuble Kissi, 4ème étage, Bureau N°7, Oujda
Téléphone : 0620002066
Activité : Agence de marketing digital


STAGIAIRE

Nom et prénom : {{nom_complet}}
Numéro de carte nationale : {{cin}}
Date et lieu de naissance : {{date_naissance}} {{lieu_naissance}}
Adresse : {{adresse}}


ARTICLE 1 : ÉTUDES ET FORMATION
Nature : {{formation}}
Durée du stage : {{duree_mois}} mois (du {{date_debut}} au {{date_fin}})


ARTICLE 2 : OBJECTIFS DU STAGE
Le stage a pour objectif de permettre au stagiaire de mettre en pratique
les connaissances théoriques acquises lors de sa formation, conformément
aux exigences pédagogiques.


ARTICLE 3 : CONDITIONS DU STAGE
Le stagiaire s'engage à :
  • Respecter le règlement intérieur de l'entreprise.
  • Maintenir un environnement de travail 100 % professionnel.
  • Utiliser le téléphone uniquement pendant les pauses.
  • Porter une tenue correcte, respectueuse et professionnelle, reflétant
    l'image de l'entreprise.
  • Adopter un comportement professionnel en toutes circonstances.
  • Éviter tout comportement pouvant perturber la concentration ou le bon
    fonctionnement de l'équipe.
  • Respecter l'ensemble des membres de l'équipe, sans exception.
  • Garantir la confidentialité des informations obtenues.

L'entreprise s'engage à :
  • Fournir les moyens nécessaires à la réalisation des missions.
  • Assurer un encadrement approprié.

Le stagiaire conserve son statut d'étudiant pendant toute la durée du stage
et reste sous la responsabilité de son établissement d'enseignement.


ARTICLE 4 : SECRET PROFESSIONNEL
Conformément au Code Pénal marocain, le stagiaire est tenu au secret
professionnel absolu et s'engage à ne divulguer aucune information à des
tiers sans autorisation écrite de l'entreprise.


ARTICLE 5 : GRATIFICATION ET MOYENS MIS À DISPOSITION
L'entreprise mettra à disposition du stagiaire les outils et ressources
nécessaires à la bonne réalisation de ses missions.
Elle veillera également à lui fournir un encadrement de qualité, garantissant
une immersion professionnelle enrichissante et conforme aux objectifs
pédagogiques du stage.


ARTICLE 6 : ASSURANCE DU STAGE
{{le_la_stagiaire}} confirme {{quil_quelle}} est {{couvert_e}} par une
assurance de responsabilité civile couvrant l'ensemble des risques liés à
ses activités durant le stage, que cette couverture soit fournie par son
établissement de formation ou par un organisme assureur privé.
{{Il_Elle}} déclare également bénéficier d'une police d'assurance contractée
auprès d'un assureur, valable pendant toute la durée du stage, incluant la
responsabilité civile pour les dommages pouvant survenir dans le cadre de
l'exercice de ses missions en tant que stagiaire.


ARTICLE 7 : ÉVALUATION DU STAGE
À l'issue du stage :
  • Le stagiaire doit fournir un rapport de stage à son établissement.
  • Une copie sera remise à l'entreprise.
  • L'entreprise délivrera une attestation de stage.


ARTICLE 8 : NATURE JURIDIQUE DU STAGE
Le stage ne constitue en aucun cas un contrat de travail. Il n'entraîne
aucune relation de subordination juridique permanente entre les parties.


ARTICLE 9 : PROPRIÉTÉ INTELLECTUELLE
Les productions réalisées durant le stage (documents, designs, contenus, etc.)
demeurent la propriété exclusive de l'entreprise, sauf accord contraire écrit.


SIGNATURES                                              Le Stagiaire :
Fait à : Oujda, le {{date_emission}}

L'Entreprise :
```

**Règles de remplacement Convention :**
- `{{duree_mois}}` → différence en mois entre `date_debut` et `date_fin` (arrondi)
- `{{le_la_stagiaire}}` → `Le stagiaire` (homme) / `La stagiaire` (femme)
- `{{quil_quelle}}` → `qu'il` (homme) / `qu'elle` (femme)
- `{{couvert_e}}` → `couvert` (homme) / `couverte` (femme)
- `{{Il_Elle}}` → `Il` (homme) / `Elle` (femme)

---

### 📄 Document 3 — ATTESTATION DE STAGE (fin de stage)

```
NEXT GITAL SARL AU
Marketing Digital & Développement Web
Rue Mohamed V Immeuble Kissi, 4ème étage Bureau N°7 Oujda


                          ATTESTATION DE STAGE


Nous, soussignés, la société NEXT GITAL SARL AU, spécialisée en marketing
digital et développement web, dont le siège social est situé à l'Avenue
Mohamed V (Hôtel Aswan), Immeuble Kissi, 4e étage, Bureau N°7, Oujda,
représentée par M. Ibrahim Messouali,

Attestons par la présente que :

{{civilite}} {{nom_complet}} a effectué un stage au sein de notre entreprise,
du {{date_debut}} au {{date_fin}}, au sein du département de
{{departement}}.

Durant cette période, {{civilite}} {{nom_complet}} a accompli les tâches qui
lui ont été {{confiees}}, en respectant les consignes et les délais fixés.

La présente attestation lui est délivrée à sa demande pour servir et valoir
ce que de droit.

Fait à Oujda, le {{date_emission}}

Le Représentant Légal
M. Ibrahim Messouali
Gérant – NEXT GITAL SARL AU
```

**Règles de remplacement :**
- `{{confiees}}` → `confiées` (toujours féminin, accord avec "tâches")
- même logique civilité que Document 1

---

## 🛠️ Architecture des fichiers à créer

```
src/
├── pages/
│   ├── Stagiaires.tsx              # Liste + recherche + filtres
│   └── StagiaireDetail.tsx         # Vue détail + actions PDF
├── components/
│   └── stagiaires/
│       ├── StagiaireForm.tsx       # Formulaire création/édition
│       ├── StagiaireTable.tsx      # Tableau
│       └── PdfActionsMenu.tsx      # Menu génération PDFs
├── lib/
│   ├── entreprise.ts               # Constantes NEXT GITAL
│   ├── stagiairesService.ts        # CRUD Supabase
│   └── pdf/
│       ├── attestationAcceptation.ts
│       ├── conventionStage.ts
│       ├── attestationStage.ts
│       └── pdfHelpers.ts           # accords, formatage dates, civilité
└── hooks/
    └── useStagiaires.ts            # React Query / state hook
```

### Migration Supabase

Créer `supabase/migrations/YYYYMMDD_create_stagiaires.sql` avec :
- Table `stagiaires`
- Index sur `tenant_id`, `cin`, `email`
- Trigger `updated_at`
- RLS policies (SELECT/INSERT/UPDATE/DELETE) filtrées par `tenant_id`

---

## 🧮 Helpers à implémenter (`pdfHelpers.ts`)

```ts
export function civilite(genre: 'homme' | 'femme'): string {
  return genre === 'homme' ? 'M.' : 'Mme';
}

export function accordFeminin(genre: 'homme' | 'femme'): string {
  return genre === 'femme' ? 'e' : '';
}

export function pronom(genre: 'homme' | 'femme', forme: 'sujet' | 'article'): string {
  if (forme === 'sujet') return genre === 'homme' ? 'Il' : 'Elle';
  return genre === 'homme' ? 'Le' : 'La';
}

export function formatDateFR(date: string | Date): string {
  // → JJ/MM/AAAA
}

export function dureeEnMois(debut: string, fin: string): number {
  // calcul mois entre deux dates
}
```

---

## 🎨 Design / UX

- **Cohérence visuelle** : utiliser les mêmes composants UI que les autres pages (`src/components/ui/`)
- **Logo** : si un logo NEXT GITAL existe dans `public/`, l'intégrer en en-tête des PDFs
- **Responsive** : conformer à `RESPONSIVE_GUIDELINES.md`
- **Sidebar** : ajouter une entrée "Stagiaires" dans la navigation (cf. `src/components/layout/`)
- **i18n** : si le projet utilise un système de traduction, suivre la même convention

---

## ✅ Critères d'acceptation

1. [ ] Migration Supabase appliquée, table `stagiaires` créée avec RLS multi-tenant
2. [ ] Page `/stagiaires` accessible depuis la sidebar
3. [ ] Formulaire de création fonctionnel avec validation
4. [ ] Liste avec recherche, filtres, pagination
5. [ ] CRUD complet (Create / Read / Update / Delete)
6. [ ] Les 3 PDFs se génèrent correctement avec accords grammaticaux (M./Mme, accepté/acceptée, etc.)
7. [ ] Dates formatées en JJ/MM/AAAA partout
8. [ ] PDFs téléchargeables avec nom de fichier explicite (ex: `Convention_Stage_YOUNES_MOUQLA.pdf`)
9. [ ] Aperçu PDF avant téléchargement (modal ou nouvelle page)
10. [ ] Aucune erreur TypeScript / ESLint
11. [ ] Tests Playwright basiques (création stagiaire + génération d'un PDF)

---

## 🚀 Étapes recommandées d'exécution

1. **Lire** `package.json`, `ARCHITECTURE_TENANT.md`, et 1–2 pages existantes (`Contrats.tsx`, `Devis.tsx`) pour comprendre les conventions.
2. **Créer la migration Supabase** et l'appliquer.
3. **Créer les constantes entreprise + helpers PDF**.
4. **Implémenter le service CRUD** (`stagiairesService.ts`).
5. **Créer la page liste + formulaire**.
6. **Implémenter les 3 générateurs PDF** un par un, en testant avec des données réelles (ex: Younes Mouqla, Chada Arbaoui, Fatima Zahra Dokali — données fournies par l'utilisateur).
7. **Ajouter l'entrée dans la sidebar**.
8. **Tester** la golden path en navigateur (création → édition → génération des 3 PDFs → vérification visuelle).
9. **Valider** TypeScript, ESLint, tests.

---

## 📌 Notes importantes

- **Ne pas demander de clarification pendant l'implémentation** — toutes les informations sont dans ce document.
- **Respecter scrupuleusement les templates** des 3 documents (textes, structure, ordre des articles).
- **Gérer les accords français** (masculin/féminin) — c'est critique pour le rendu professionnel.
- **Les 3 stagiaires de référence** (Younes Mouqla, Chada Arbaoui, Fatima Zahra Dokali) peuvent être utilisés comme données de seed/test.
- **Date du jour** = utiliser `new Date()` au moment de la génération du PDF, pas une date hardcodée.
