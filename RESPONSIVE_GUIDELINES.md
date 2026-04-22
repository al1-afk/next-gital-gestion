# Responsive Guidelines — GestiQ

Guide technique pour tout code React/Tailwind ajouté à ce projet.
Cible : iPhone Safari + Android Chrome (50/50 trafic PME Maroc).

---

## 1. Règle d'or : **mobile-first**

Écris d'abord la version mobile (sans préfixe), puis ajoute les variants `sm:` / `md:` / `lg:` / `xl:` pour élargir.
**Jamais l'inverse.**

```tsx
// ✅ bon
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4" />

// ❌ mauvais — part du desktop et "dégrade" vers le mobile
<div className="grid grid-cols-4 max-md:grid-cols-1" />
```

## 2. Breakpoints

| Classe Tailwind | Largeur ≥ | Cible |
|---|---|---|
| (défaut) | 0 px | Mobile (iPhone SE 375, Galaxy S20 360) |
| `sm:` | 640 px | Mobile large / petit tablet |
| `md:` | 768 px | Tablette (iPad Mini, A51 landscape) |
| `lg:` | 1024 px | Desktop (sidebar visible permanente) |
| `xl:` | 1280 px | Wide desktop |

## 3. Hauteurs : `dvh` obligatoire

Sur Safari iOS, `100vh` inclut la barre d'URL → déborde de 60-80 px. Sur Chrome Android, la barre qui apparaît/disparaît provoque un reflow.

```tsx
// ✅
<div className="min-h-[100dvh]" />   // ou h-[100dvh] / max-h-[90dvh]
// ❌
<div className="min-h-screen" />      // = 100vh
```

## 4. Safe-area iOS (notch, Dynamic Island, home indicator)

Prérequis : `<meta name="viewport" content="..., viewport-fit=cover">` dans `index.html` (déjà fait).

Ensuite, sur tout élément plein écran ou `fixed` collé aux bords :

```tsx
<header className="pt-[env(safe-area-inset-top)]">…</header>
<aside  className="pt-[env(safe-area-inset-top)] pb-[env(safe-area-inset-bottom)]">…</aside>
<main   className="pb-[calc(1rem+env(safe-area-inset-bottom))]">…</main>
```

## 5. Inputs ≥ 16 px (anti-zoom Safari iOS)

Safari iOS zoome automatiquement dès qu'on focus un `<input>` / `<textarea>` dont la font-size est < 16 px. Utiliser :

```tsx
<input className="text-base sm:text-sm" />
```

Le composant `<Input>` (`src/components/ui/input.tsx`) et la classe utilitaire `.input-field` (`src/index.css`) appliquent déjà cette règle. Si tu écris un `<textarea>` ad-hoc, reproduis le pattern.

## 6. Touch targets ≥ 44×44 px

Apple HIG : 44×44 px minimum. Matériel Design : 48×48 px. En pratique on vise 44 px :

```tsx
// ✅ bouton confortable sur mobile
<button className="h-11 px-4">Action</button>
// ✅ bouton icône
<button className="w-11 h-11 flex items-center justify-center">…</button>
```

Entre deux boutons mobiles : minimum 8 px (`gap-2`).

## 7. Montants monétaires — helper dédié

`formatCurrency` (2 décimales) = trop long sur mobile. Utiliser `formatCurrencyCompact` sous `sm:` :

```tsx
import { formatCurrency, formatCurrencyCompact, useIsMobileViewport } from '@/lib/utils'

const isMobile = useIsMobileViewport()
const fmt = isMobile ? formatCurrencyCompact : formatCurrency
// "64 180,00 MAD" (desktop) → "64,2K MAD" (mobile)
```

Et **toujours** entourer la valeur d'un `<p className="truncate min-w-0">` dans un flex parent `min-w-0`.

## 8. Grilles KPI

Pattern canonique :

```tsx
<div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-3 sm:gap-4">…</div>
// pour 3 KPIs :
<div className="grid grid-cols-1 sm:grid-cols-3 gap-3 sm:gap-4">…</div>
```

Jamais `grid-cols-3` figé sur mobile : iPhone SE 375 px ÷ 3 = 125 px par carte, pas assez pour un montant MAD.

## 9. Tableaux

Pour tout `<table>` large, utiliser la classe `.table-scroll` comme wrapper :

```tsx
<div className="card-premium overflow-hidden">
  <div className="table-scroll">
    <table className="w-full">…</table>
  </div>
</div>
```

`.table-scroll` (voir `src/index.css`) force `overflow-x-auto` + `min-width: 640px` sur la table + smooth scroll iOS. Sur desktop, la table remplit son parent normalement.

**Amélioration future (P2) :** convertir les list-pages critiques (Factures, Prospects) en cards stackées `sm:hidden` + table `hidden sm:table`. Pattern :

```tsx
{/* Desktop */}
<div className="hidden sm:block"><Table /></div>
{/* Mobile */}
<div className="sm:hidden space-y-2">{rows.map(r => <Card key={r.id} {...r} />)}</div>
```

## 10. Positions fixées

Tout `position: fixed` collé à un bord doit :
- utiliser `dvh` (pas `vh`) pour la hauteur si applicable
- respecter les safe-areas
- sur mobile prendre `w-full` et laisser `sm:w-[…]` pour desktop

```tsx
// ✅ drawer responsive
<aside className="fixed right-0 top-0 bottom-0 w-full sm:w-[400px] max-w-full
                  pt-[env(safe-area-inset-top)] pb-[env(safe-area-inset-bottom)]" />
```

## 11. Dropdowns / popovers

Largeur responsive obligatoire — pas de `w-[360px]` figé :

```tsx
<motion.div className="w-[calc(100vw-1rem)] max-w-[360px] sm:w-[360px]" />
```

## 12. Ne JAMAIS faire

| Anti-pattern | Pourquoi | À la place |
|---|---|---|
| `width: 400px` | Fixe sur tous les écrans | `w-full sm:w-[400px]` |
| `overflow: hidden` sans raison | Cache les bugs au lieu de les fixer | `overflow-x-auto` ou vrai fix |
| `!important` partout | Signe de CSS mal architecturé | Remonter la spécificité proprement |
| `window.innerWidth < 768` | JS pour un problème CSS | `md:hidden` / `md:block` |
| `user-agent` sniffing | Fragile, ne reflète pas la réalité | Feature queries + `matchMedia` |
| Media queries manuelles | Fragmente le système | `sm:` / `md:` / `lg:` Tailwind |

## 13. Checklist QA par release

Avant chaque PR touchant l'UI, vérifier sur Chrome DevTools avec les 6 presets (iPhone SE, iPhone 14 Pro, 14 Pro Max, Galaxy S20, Galaxy A51, iPad Mini) :

- [ ] Zéro scroll horizontal (sauf intentionnel : table-scroll, pipeline Kanban)
- [ ] Tous les textes lisibles sans zoom
- [ ] Tous les boutons atteignables au doigt (≥ 44 px)
- [ ] Le header complet visible, breadcrumb tronqué proprement
- [ ] Les modales/drawers tiennent dans le viewport (dvh)
- [ ] Les inputs ne déclenchent pas de zoom sur iOS
- [ ] Le mode offline affiche la bannière push-down (pas d'overlay)
- [ ] `npm run test:visual` passe avec `maxDiffPixelRatio ≤ 1%`

## 14. Lancer la suite visuelle Playwright

```bash
# Installation (une fois)
npm install --save-dev @playwright/test
npx playwright install --with-deps chromium webkit

# Exécuter
npm run test:visual

# Accepter de nouveaux baselines (après refactor UI volontaire)
npm run test:visual:update

# Voir le rapport HTML
npx playwright show-report tests/visual/report
```

La config (`playwright.config.ts`) définit 7 projects correspondant aux presets iPhone/Samsung/iPad. Les tests :
- `responsive.spec.ts` : absence de scroll horizontal + touch targets + snapshots full-page.

Snapshots stockés dans `tests/visual/snapshots/`. À committer.

## 15. Ressources

- [web.dev — Safari iOS `dvh`](https://web.dev/viewport-units/)
- [Apple HIG — Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
- [Tailwind — responsive design](https://tailwindcss.com/docs/responsive-design)
- [env(safe-area-inset-*) — MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/env)
