// Service worker for the installable app.
// Policy: never cache the app page and never touch database requests. Only the third-party library
// scripts (React, Chart.js, ...) are cached, so a phone can't open a stale app or an empty offline copy
// of the data that looks like lost records.
const CACHE = 'cabin-ledger-libs-v1';
const LIB_HOSTS = ['cdnjs.cloudflare.com', 'cdn.jsdelivr.net'];

self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (e) => {
  e.waitUntil(caches.keys()
    .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
    .then(() => self.clients.claim()));
});
self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET' || !LIB_HOSTS.includes(new URL(req.url).hostname)) return;
  e.respondWith(caches.open(CACHE).then((cache) => cache.match(req).then((cached) => {
    const net = fetch(req).then((res) => { if (res && res.status === 200) cache.put(req, res.clone()); return res; }).catch(() => cached);
    return cached || net; // stale-while-revalidate
  })));
});
