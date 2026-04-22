# AUDIT RESPONSIVE — GestiQ

> Phase 1 — Rapport d'audit **en lecture seule**. Aucun code n'a été modifié.
> Stack : React 19 + Vite 8 + Tailwind CSS 3 + Radix UI + Framer Motion + Recharts.
> Cible : PME marocaines — 50% iPhone (Safari) / 50% Android (Chrome).

---

## 🔎 Résumé exécutif

| Sévérité | Nombre de bugs identifiés |
|---|---|
| 🔴 Critique | **8** |
| 🟡 Majeur | **11** |
| 🟢 Mineur | **7** |

**Cause racine #1 (explique 4 des bugs critiques des screenshots) :**
le `<Header>` en position `fixed` utilise `left-16` / `left-64` (alignés sur la sidebar) **sur tous les viewports**, y compris mobile où la sidebar est cachée (`hidden md:block`). Résultat : sur iPhone SE (375 px) le header démarre à `256px` → il ne reste que **119 px** pour afficher le menu burger + breadcrumb + recherche + bell + avatar. D'où le breadcrumb coupé, les icônes qui débordent, le layout qui "saute" hors de l'écran.

**Cause racine #2 :** `<meta viewport>` dans [index.html:6](index.html#L6) n'a pas `viewport-fit=cover` → les safe-areas iOS (notch, Dynamic Island, home indicator) ne sont jamais respectées.

**Cause racine #3 :** `<Input>` utilise `text-sm` (= 14 px) — en dessous du seuil de 16 px requis par iOS Safari → **zoom automatique** à chaque focus sur un input (perturbe toutes les recherches et formulaires sur iPhone).

**Cause racine #4 :** les grilles KPI sont figées en `grid-cols-3` ou `grid-cols-4` sans breakpoint mobile, forçant l'affichage des montants en très petit caractère → troncature visible sur les screenshots (« 64.180,00 M… »).

---

## 🔴 CRITIQUE — casse la fonctionnalité

### C1. Header pousse hors-écran sur mobile
- **Fichier :** [src/components/layout/Header.tsx:148-156](src/components/layout/Header.tsx#L148-L156)
- **Problème :** `className={cn('fixed top-0 right-0 ... ', collapsed ? 'left-16' : 'left-64')}` — la classe `left-64` s'applique aussi en dessous de `md:` alors que la sidebar y est masquée par [AppLayout.tsx:44](src/components/layout/AppLayout.tsx#L44) (`hidden md:block`).
- **Conséquence :** sur iPhone SE (375 px), le header est rendu dans un `left: 256px → right: 0` = 119 px de large. Tous les bugs visuels du header (breadcrumb coupé, icônes qui se chevauchent) viennent de là.
- **Attendu :** `left-0 md:left-64` (et `md:left-16` si collapsed). Et `px-3 md:px-5`.

### C2. Pas de `viewport-fit=cover` → safe-area iOS jamais respectée
- **Fichier :** [index.html:6](index.html#L6)
- **Actuel :** `<meta name="viewport" content="width=device-width, initial-scale=1.0" />`
- **Attendu :** `<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">`.
- **Conséquence :** sur iPhone à notch / Dynamic Island, le header passe sous la barre d'état; le contenu bas passe sous le home indicator. Les règles `env(safe-area-inset-*)` sont invisibles sans cette directive.

### C3. Inputs < 16 px → zoom Safari iOS sur focus
- **Fichier :** [src/components/ui/input.tsx:20](src/components/ui/input.tsx#L20)
- **Problème :** `'flex h-10 w-full ... text-sm ...'` → `text-sm` = 14 px.
- **Conséquence :** Safari iOS zoome automatiquement la page à chaque focus sur un champ (recherche globale, forms factures/clients/prospects, modale de login, etc.). L'utilisateur doit ensuite dézoomer manuellement.
- **Même problème** sur `<textarea>` : [src/components/ui/textarea.tsx] et [src/pages/Factures.tsx:510-514](src/pages/Factures.tsx#L510-L514).

### C4. KPI cards Factures/BC/Chèques/Hébergements : `grid-cols-3` figé
- **Fichiers :** [Factures.tsx:628](src/pages/Factures.tsx#L628), [Abonnements.tsx:73](src/pages/Abonnements.tsx#L73), [ChequesEmis.tsx:80](src/pages/ChequesEmis.tsx#L80), [Hebergements.tsx:73](src/pages/Hebergements.tsx#L73), [Contrats.tsx:368](src/pages/Contrats.tsx#L368), [Devis.tsx:1457](src/pages/Devis.tsx#L1457).
- **Problème :** `<div className="grid grid-cols-3 gap-4">` sans `sm:` ni `lg:`.
- **Conséquence :** 3 cartes sur 375 px ⇒ ~113 px de large par carte. Un montant formaté `Intl.NumberFormat('fr-MA', 'currency')` (`"64 180,00 MAD"`) ne rentre pas → troncature visible sur le screenshot. Le problème est aggravé par `text-xl font-extrabold` sur la valeur ([Factures.tsx:635](src/pages/Factures.tsx#L635)).
- **Attendu :** `grid-cols-1 sm:grid-cols-3 gap-3 sm:gap-4` et `text-lg sm:text-xl`.

### C5. KPI Dashboard : `grid-cols-2 xl:grid-cols-4` — ok sur petit écran, mais valeurs non compactées
- **Fichier :** [src/pages/Dashboard.tsx:385-414](src/pages/Dashboard.tsx#L385-L414), helper [src/lib/utils.ts:8-14](src/lib/utils.ts#L8-L14)
- **Problème :** `formatCurrency` utilise `minimumFractionDigits: 2` et jamais `notation: 'compact'`. Sur mobile on lit « 64 180,00 MAD » dans une colonne de 160 px → affichage trop long. Combiné à `text-2xl font-extrabold` ([Dashboard.tsx:118](src/pages/Dashboard.tsx#L118)), la valeur tronque ou déborde.
- **Attendu :** variante compacte utilisée sous `640 px` — p.ex. `formatCurrencyCompact(n)` avec `Intl.NumberFormat('fr-MA', { notation: 'compact', maximumFractionDigits: 1 })` → `"64,2K MAD"`.

### C6. Notification « Hors ligne » couvre le contenu
- **Fichier :** [src/hooks/useNetworkStatus.ts:15-22](src/hooks/useNetworkStatus.ts#L15-L22)
- **Problème :** `toast.error('Hors ligne', { duration: Infinity, id: 'offline-toast' })`. Sonner `<Toaster position="bottom-right" />` ([App.tsx:124](src/App.tsx#L124)) → sur mobile le toast se place en bas-droite en overlay permanent au-dessus des CTA principaux (Nouvelle facture, FAB, etc.).
- **Attendu :** bannière de rang (push-down) sous le header, pas un overlay. Voir spec utilisateur (« PUSH le content, pas overlay »).

### C7. `min-h-screen` + `h-screen` (bug 100vh Safari iOS)
- **Fichiers :** [AppLayout.tsx:42,60,97](src/components/layout/AppLayout.tsx#L42), [Sidebar.tsx:107](src/components/layout/Sidebar.tsx#L107), [DevisPreview.tsx:53](src/pages/DevisPreview.tsx#L53), [Landing.tsx:187](src/pages/Landing.tsx#L187), [Taches.tsx:868](src/pages/Taches.tsx#L868) (`h-full` dans drawer fixed), [Devis.tsx:1605](src/pages/Devis.tsx#L1605) (`!h-screen !max-h-screen` sur dialog plein écran), [Auth.tsx:38](src/pages/Auth.tsx#L38).
- **Problème :** Tailwind `h-screen`/`min-h-screen` ⇒ `100vh`. Sur Safari iOS, `100vh` inclut la barre d'URL même quand elle est visible → le contenu déborde de 60-80 px. Sur Chrome Android, la barre qui apparaît/disparaît provoque un reflow.
- **Attendu :** migration `h-screen → h-[100dvh]` et `min-h-screen → min-h-[100dvh]` (avec fallback). Tailwind 3.4 supporte `h-dvh` / `min-h-dvh` — disponible dans le projet.

### C8. Sidebar mobile drawer : `h-screen`, pas de safe-area
- **Fichier :** [src/components/layout/AppLayout.tsx:60](src/components/layout/AppLayout.tsx#L60) + [Sidebar.tsx:107](src/components/layout/Sidebar.tsx#L107)
- **Problème :** Drawer `h-screen` + bouton de fermeture à `top-4 right-4`. Sur iPhone à notch, le bouton passe sous l'encoche; sur Android avec nav gestures, le bas du menu passe sous la barre de gestes. Pas de `pt-[env(safe-area-inset-top)]` ni `pb-[env(safe-area-inset-bottom)]`.

---

## 🟡 MAJEUR — dégrade l'UX

### M1. Breadcrumb du header sans `truncate`
- [Header.tsx:163-169](src/components/layout/Header.tsx#L163-L169) — `<nav>` contient directement `<span>` texte sans `min-w-0` ni `truncate`. Pour `Statistiques`, `Bons de commande`, `Journal d'activité` : débordement quasi garanti dès qu'on cumule plusieurs segments.
- **Attendu :** `<nav className="flex items-center gap-1.5 text-sm min-w-0 flex-1">` + `<span className="truncate">` sur le dernier segment.

### M2. Bouton « Rechercher… » n'affiche jamais le texte sur mobile
- [Header.tsx:178-183](src/components/layout/Header.tsx#L178-L183) : le texte et la kbd sont en `hidden md:inline/flex`. OK, mais combiné à C1 (header hors-écran), l'icône de recherche disparaît elle aussi.

### M3. Tables list-page : 7-8 colonnes + `overflow-x-auto` sans "card fallback"
- 11 tables trouvées (voir `grep <table`) : [Factures](src/pages/Factures.tsx#L724), [Devis](src/pages/Devis.tsx#L1493), [Prospects](src/pages/Prospects.tsx#L1199), [Depenses](src/pages/Depenses.tsx#L469), [ChequesRecus](src/pages/ChequesRecus.tsx#L110), [ChequesEmis](src/pages/ChequesEmis.tsx#L105), [BonsCommande](src/pages/BonsCommande.tsx#L77), [Produits](src/pages/Produits.tsx#L68), 4× [Equipe](src/pages/Equipe.tsx#L290), [ImportExportButtons](src/components/ImportExportButtons.tsx#L204).
- **Problème :** toutes utilisent `<div className="overflow-x-auto"><table className="w-full">`. Sur mobile, l'utilisateur a 8 colonnes + header sticky + scroll horizontal → très mauvaise UX (spec utilisateur recommande cards stackées).
- **Attendu :** version `<div className="hidden sm:block">` pour la table + `<div className="sm:hidden space-y-2">` pour des `<CardRow>` empilées.

### M4. Dropdown alertes : `w-[360px]` figé
- [Header.tsx:225](src/components/layout/Header.tsx#L225) — sur iPhone SE (375 px), le popover aligné à droite dépasse à gauche (negative left) ou est clippé. Déjà problématique avec le bug C1.
- **Attendu :** `w-[min(360px,calc(100vw-16px))]` ou `w-[calc(100vw-1rem)] sm:w-[360px]`.

### M5. PWA install banner : largeur OK, mais bas d'écran sous home indicator
- [PwaInstallBanner.tsx:48-50](src/components/PwaInstallBanner.tsx#L48-L50) : `bottom-5` sans `env(safe-area-inset-bottom)`. Sur iPhone 14 Pro, le bouton « Installer » se trouve à ~20 px du home indicator → peu ergonomique.

### M6. Page header Factures : `flex gap-2` sur les CTAs → débordement
- [Factures.tsx:615-624](src/pages/Factures.tsx#L615-L624) : `<ImportExportButtons>` + `<Button>Nouvelle facture</Button>` alignés horizontalement → sur mobile la ligne dépasse. Classe `page-header` ([index.css:388-391](src/index.css#L388-L391)) passe `flex-col` sur mobile mais le bloc CTAs reste `flex` non-wrap.

### M7. Pipeline Kanban : largeur fixe 220 px, scroll horizontal
- [Prospects.tsx:1254,1266](src/pages/Prospects.tsx#L1254) : `<div className="flex gap-3 overflow-x-auto pb-4" style={{ minHeight: 420 }}>` + colonnes `style={{ width: 220 }}`. Ça reste utilisable mais `minHeight: 420` force une hauteur qui bloque le scroll vertical sur mobile.
- **Attendu :** `min-h-[420px]` (préserver) + sur mobile offrir bascule vers vue liste par défaut.

### M8. Drawer détail Prospect : `max-w-[480px]`, pas de safe-area
- [Prospects.tsx:325](src/pages/Prospects.tsx#L325) : drawer prend 100% de largeur sur mobile (OK) mais `top-0 bottom-0` sans `pt-[env(safe-area-inset-top)]`. Bouton close sous le notch.
- Idem [Taches.tsx:868](src/pages/Taches.tsx#L868) drawer `w-[400px]` — n'est PAS en `w-full` sur mobile → sur 360 px (Galaxy S20) le drawer dépasse.

### M9. Dialogs : `max-h-[90vh]` (vh, pas dvh)
- [src/components/ui/dialog.tsx:39](src/components/ui/dialog.tsx#L39) : même bug que C7. Sur Safari iOS le dialog dépasse la zone visible de 8-10%.
- Idem `DialogContent` spécifiques : [Devis.tsx:1118](src/pages/Devis.tsx#L1118) `max-h-[95vh]`.

### M10. `form-label` et inputs textarea non standardisés
- [src/index.css:441-442](src/index.css#L441-L442) `.form-label { font-size:13px }` — sous 16 px, même problème que C3 si la police se combine à un input custom.
- Plusieurs textareas inline avec `h-20` / `h-40` figé (voir [Factures.tsx:514](src/pages/Factures.tsx#L514)) — empêche la croissance sur mobile.

### M11. Espacements de page non adaptés mobile
- [AppLayout.tsx:107](src/components/layout/AppLayout.tsx#L107) : `p-4 md:p-8`. Spec demande progression `16 / 24 / 32 px` (mobile/tablet/desktop) → actuellement saut direct `16 → 32 px`, rien pour la tablette.

---

## 🟢 MINEUR — esthétique / pulissage

### m1. Hauteur header 64 px sur mobile
- Header `h-16` = 64 px. Spec utilisateur : `56 px mobile / 64 px desktop`. Impact faible mais 8 px gagnés utiles sur iPhone SE.
- [Header.tsx:150](src/components/layout/Header.tsx#L150) + padding top de `<main>` `pt-16` ([AppLayout.tsx:97](src/components/layout/AppLayout.tsx#L97)).

### m2. Hero card Dashboard : `p-7` sur tous les viewports
- [Dashboard.tsx:279](src/pages/Dashboard.tsx#L279) : padding fixe = 28 px → un peu gros sur iPhone SE. `p-5 sm:p-7` plus approprié.

### m3. Tailles d'icônes en px arbitraires
- Plusieurs `w-[34px] h-[34px]` ([Prospects.tsx:106](src/pages/Prospects.tsx#L106)) — non-bloquant mais casse le système de scale Tailwind.

### m4. Animations `transform: translateX(2px)` au hover sidebar
- [index.css:251](src/index.css#L251) — sur mobile (touch) provoque un "rebond" non intentionnel après le tap. `@media (hover: hover)` conseillé.

### m5. `text-[10px]` et `text-[11px]` abondants
- ~35 occurrences recensées. Lisibilité limite sur iPhone SE (densité de pixels standard). À revoir pour min 12 px hors badges.

### m6. Blobs Landing `w-[800px]` qui cassent le layout mobile
- [Landing.tsx:461](src/pages/Landing.tsx#L461) : parent a `overflow-x-clip` ([Landing.tsx:187](src/pages/Landing.tsx#L187)) donc pas de scroll, mais les blobs débordent visuellement → OK mais à surveiller.

### m7. Scrollbar globale : 5 px + `::-webkit-scrollbar`
- [index.css:227](src/index.css#L227) : WebKit uniquement → Chrome/Safari OK, Firefox ignoré. Spec Tailwind Forms déjà chargé ([package.json:40](package.json#L40)). Impact réel faible.

---

## 📋 Checklist « anti-patterns » relevés

| Anti-pattern (spec) | Occurrences clés |
|---|---|
| ❌ width fixe en pixels | [Taches.tsx:868](src/pages/Taches.tsx#L868) `w-[400px]`, [Prospects.tsx:1266](src/pages/Prospects.tsx#L1266) `width: 220`, [Header.tsx:225](src/components/layout/Header.tsx#L225) `w-[360px]`, [Landing.tsx:30-32,407,461](src/pages/Landing.tsx#L30) blobs |
| ❌ height fixe | [Factures.tsx:734](src/pages/Factures.tsx#L734) `style={{ width: 116 }}`, textareas `h-20/h-40` |
| ❌ `100vh` au lieu de `100dvh` | **10 fichiers** — voir C7 |
| ❌ Absence safe-area-inset | **Partout** — aucune occurrence `env(safe-area-inset-*)` dans le projet |
| ❌ `px` au lieu de `rem/em` pour fonts | [index.css:149-150](src/index.css#L149) (`.text-label`, `.text-table-header` en px), [index.css:214](src/index.css#L214) (`body { font-size: 14px }`), nombreuses classes `text-[Npx]` |
| ❌ user-agent sniffing / JS pour mobile | [AppLayout.tsx:76](src/components/layout/AppLayout.tsx#L76) `window.innerWidth < 768` — peut être remplacé par pure CSS `md:hidden` sur le bouton menu |
| ❌ Media queries manuelles | **Aucune** — bon point (tout Tailwind) |
| ❌ `!important` | [Devis.tsx:1605](src/pages/Devis.tsx#L1605) `!left-0 !top-0 !translate-x-0 …` pour forcer fullscreen dialog — légitime mais à documenter |

---

## 📱 Tests visuels recommandés (Phase 4 à venir)

Aucun snapshot Playwright / test responsive n'existe actuellement. À mettre en place :
- iPhone SE (375×667) — référence "pire cas"
- iPhone 14 Pro (393×852) — safe-area / Dynamic Island
- iPhone 14 Pro Max (430×932)
- Samsung Galaxy S20 (360×800)
- Samsung Galaxy A51 (412×914)
- iPad Mini (768×1024) — basculement sidebar
- iPad Pro (1024×1366)

---

## ✅ Points positifs (à préserver)

- **Mobile-first déjà amorcé** sur : classes `page-header` (`flex-col sm:flex-row`), hero dashboard (`flex-col sm:flex-row`), grille clients (`grid-cols-1 md:grid-cols-2 xl:grid-cols-3`), grille KPI dashboard (`grid-cols-2 xl:grid-cols-4`).
- **Design tokens centralisés** dans [index.css](src/index.css) (`--surface-*`, `--shadow-*`, `--kpi-*-*`) → refactor rapide.
- **Drawer mobile sidebar** déjà implémenté ([AppLayout.tsx:49-72](src/components/layout/AppLayout.tsx#L49-L72)) — reste à corriger safe-area + réorienter le menu burger côté gauche (LTR français, actuellement le menu est affiché à gauche du breadcrumb — ✅ conforme).
- **Radix UI** utilisé pour Dialog/Dropdown/Select → a11y mobile correcte "out of the box".
- **Aucune media query manuelle** — tout Tailwind, donc refactor linéaire.
- **Toasts (Sonner)** déjà en place — il suffit de les reconfigurer pour le cas offline.

---

## 🧭 Plan de correction proposé (Phase 2 — à valider)

Ordre de traitement par **ROI impact / effort** :

1. **[30 min]** Fixer `index.html` (viewport-fit=cover) + `<Input>`/`<Textarea>` → `text-base` → résout C2 + C3.
2. **[45 min]** Header `left-0 md:left-X` + breadcrumb `truncate` + hauteur `h-14 md:h-16` → résout C1 + M1 + m1.
3. **[20 min]** `useNetworkStatus` → bannière push-down au lieu de toast infinite → résout C6.
4. **[30 min]** `h-screen` → `h-dvh`, `min-h-screen` → `min-h-dvh`, `max-h-[90vh]` → `max-h-[90dvh]` sur les 10 fichiers → résout C7.
5. **[20 min]** Safe-area : utility classes Tailwind `pt-[env(safe-area-inset-top)]` + `pb-[env(safe-area-inset-bottom)]` sur Header, Sidebar mobile drawer, PwaInstallBanner, dialogs fullscreen → résout C8 + M5 + M8.
6. **[1 h]** KPI cards : pattern `grid-cols-1 sm:grid-cols-3` + helper `formatCurrencyCompact` + texte `text-lg sm:text-xl` sur les 6 pages listées → résout C4 + C5.
7. **[2 h]** Tables → card-stack mobile : créer `<ResponsiveTable>` ou pattern `<div className="hidden sm:block">…<div className="sm:hidden">` sur les 11 tables → résout M3.
8. **[30 min]** Dropdown alertes, drawers : largeurs en `w-[min(…, 100vw - 16px)]` → résout M4 + M8.
9. **[20 min]** `form-label`, labels, tailles minimales de texte → résout M10 + m5.
10. **[1 h]** Mise en place Playwright + captures baseline → Phase 5.

**Budget total estimé : ~6 h** pour couvrir les 8 critiques + 11 majeurs.

---

**En attente de validation avant de démarrer la Phase 2.**
