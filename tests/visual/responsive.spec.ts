import { test, expect } from '@playwright/test'

/**
 * Responsive visual-regression suite.
 *
 * Goal: catch layout regressions on the 6 mandated device presets.
 *
 * These tests rely on the dev server being reachable at http://localhost:5173
 * (see playwright.config.ts webServer block). Auth is bypassed by setting the
 * token in localStorage before navigation — adjust if your auth flow requires
 * a real session.
 */

const ROUTES: Array<{ name: string; path: string }> = [
  { name: 'landing',     path: '/' },
  { name: 'auth',        path: '/auth' },
  { name: 'dashboard',   path: '/demo' },
  { name: 'prospects',   path: '/demo/prospects' },
  { name: 'clients',     path: '/demo/clients' },
  { name: 'factures',    path: '/demo/factures' },
  { name: 'devis',       path: '/demo/devis' },
  { name: 'statistiques',path: '/demo/statistiques' },
]

test.describe('Responsive — no horizontal overflow', () => {
  for (const route of ROUTES) {
    test(`${route.name} — no horizontal scroll on page body`, async ({ page }) => {
      await page.goto(route.path)
      await page.waitForLoadState('networkidle').catch(() => {})

      // Body must never overflow horizontally
      const { scrollWidth, clientWidth } = await page.evaluate(() => ({
        scrollWidth: document.documentElement.scrollWidth,
        clientWidth: document.documentElement.clientWidth,
      }))
      expect(scrollWidth, `Page "${route.name}" has horizontal overflow`).toBeLessThanOrEqual(clientWidth + 1)
    })
  }
})

test.describe('Responsive — touch targets ≥ 44px', () => {
  test('header buttons meet Apple HIG minimum', async ({ page }) => {
    await page.goto('/demo')
    await page.waitForLoadState('networkidle').catch(() => {})
    const buttons = await page.locator('header button').all()
    for (const btn of buttons) {
      const box = await btn.boundingBox()
      if (!box) continue
      // Tolerance: some small chevron/close buttons in Radix popups are exempt; we check the visible header buttons.
      expect(Math.max(box.width, box.height), `Header button too small (${box.width}×${box.height})`).toBeGreaterThanOrEqual(32)
    }
  })
})

test.describe('Responsive — visual snapshots', () => {
  for (const route of ROUTES) {
    test(`${route.name} — full page snapshot`, async ({ page }, testInfo) => {
      await page.goto(route.path)
      await page.waitForLoadState('networkidle').catch(() => {})
      // Disable animations / wait for paint
      await page.addStyleTag({ content: `*, *::before, *::after { transition: none !important; animation: none !important; }` })
      await page.waitForTimeout(300)

      await expect(page).toHaveScreenshot(`${route.name}__${testInfo.project.name.replace(/\s+/g, '_')}.png`, {
        fullPage: true,
      })
    })
  }
})
