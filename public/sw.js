/* GestiQ Service Worker
   - Network-first for HTML navigations so deploys are picked up
     automatically on the next page load.
   - Cache-first for hashed static assets (Vite emits content hashes,
     so they are safe to serve from cache indefinitely).
   - API requests are never intercepted; the offline IndexedDB layer
     handles application data. */

const CACHE = 'gestiq-v3'
const PRECACHE = ['/', '/manifest.json']

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c => c.addAll(PRECACHE)).then(() => self.skipWaiting()),
  )
})

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim()),
  )
})

const isHashedAsset = url =>
  /\/assets\/.+-[A-Za-z0-9_-]{8,}\.(js|css|woff2?|ttf|otf|svg|png|jpg|jpeg|webp|avif|ico)$/.test(url)

const isApi = url => /\/api\//.test(url)

self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return
  const url = new URL(e.request.url)

  // Never cache API traffic — the offline IndexedDB layer owns it.
  if (isApi(url.pathname) || url.host !== self.location.host) return

  // Cache-first for hashed assets (immutable).
  if (isHashedAsset(url.pathname)) {
    e.respondWith(
      caches.match(e.request).then(cached =>
        cached || fetch(e.request).then(res => {
          if (res.ok) {
            const clone = res.clone()
            caches.open(CACHE).then(c => c.put(e.request, clone))
          }
          return res
        }),
      ),
    )
    return
  }

  // Network-first for HTML / navigations and everything else.
  // Falls back to cache when offline so the shell still loads.
  e.respondWith(
    fetch(e.request)
      .then(res => {
        if (res.ok) {
          const clone = res.clone()
          caches.open(CACHE).then(c => c.put(e.request, clone))
        }
        return res
      })
      .catch(() => caches.match(e.request).then(cached => cached || caches.match('/'))),
  )
})
