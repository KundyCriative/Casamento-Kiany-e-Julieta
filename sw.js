/* Shell estático versionado. Não armazenar respostas de API ou dados pessoais em cache. */
const CACHE_NAME = 'kj-wedding-shell-v2';
const APP_SHELL = ['./', './index.html', './portaria.html', './manifest.json', './icon.svg'];

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);
    await Promise.allSettled(APP_SHELL.map((asset) => cache.add(asset)));
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key)));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;
  if (url.pathname.includes('/rest/v1/') || url.pathname.includes('/auth/v1/')) return;

  event.respondWith((async () => {
    const cache = await caches.open(CACHE_NAME);
    const cached = await cache.match(request);
    try {
      const response = await fetch(request);
      if (response && response.ok && response.type === 'basic') await cache.put(request, response.clone());
      return response;
    } catch (error) {
      if (cached) return cached;
      if (request.mode === 'navigate') {
        const fallback = await cache.match('./portaria.html');
        if (fallback) return fallback;
      }
      return new Response('Conteúdo indisponível offline.', {status:503,headers:{'Content-Type':'text/plain; charset=utf-8'}});
    }
  })());
});
