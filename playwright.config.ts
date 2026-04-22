import { defineConfig, devices } from '@playwright/test'

/**
 * Playwright config — responsive visual-regression suite for GestiQ.
 * 6 device presets cover the mobile + tablet matrix from the PME Maroc target.
 * Run:
 *   npm run test:visual              # all devices
 *   npm run test:visual -- --update-snapshots   # accept new baselines
 */
export default defineConfig({
  testDir: './tests/visual',
  outputDir: './tests/visual/output',
  snapshotDir: './tests/visual/snapshots',
  timeout: 45_000,
  expect: {
    toHaveScreenshot: {
      maxDiffPixelRatio: 0.01,   // 1% tolerance (spec)
      animations: 'disabled',
      caret: 'hide',
    },
  },
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  workers: process.env.CI ? 2 : undefined,
  reporter: [['html', { outputFolder: 'tests/visual/report', open: 'never' }], ['list']],
  use: {
    baseURL: process.env.PW_BASE_URL ?? 'http://localhost:5173',
    trace: 'retain-on-failure',
    video: 'retain-on-failure',
  },
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
    timeout: 60_000,
  },
  projects: [
    { name: 'iPhone SE',         use: { ...devices['iPhone SE'] } },
    { name: 'iPhone 14 Pro',     use: { ...devices['iPhone 14 Pro'] } },
    { name: 'iPhone 14 Pro Max', use: { ...devices['iPhone 14 Pro Max'] } },
    { name: 'Galaxy S20',        use: { viewport: { width: 360, height: 800 }, userAgent: devices['Pixel 5'].userAgent, isMobile: true, hasTouch: true, deviceScaleFactor: 3 } },
    { name: 'Galaxy A51',        use: { viewport: { width: 412, height: 914 }, userAgent: devices['Pixel 5'].userAgent, isMobile: true, hasTouch: true, deviceScaleFactor: 2.625 } },
    { name: 'iPad Mini',         use: { ...devices['iPad Mini'] } },
    { name: 'iPad Pro 11',       use: { ...devices['iPad Pro 11'] } },
  ],
})
