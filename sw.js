var CACHE = 'perth-trip-v5';
var FILES = ['./', './index.html', './manifest.json', './config.js', './travellers.json',
             './icons/icon-192.png', './icons/icon-512.png',
             './fonts/source-serif-4-latin-400-normal.woff2',
             './fonts/source-serif-4-latin-400-italic.woff2',
             './fonts/source-serif-4-latin-600-normal.woff2',
             './fonts/source-serif-4-latin-600-italic.woff2',
             './fonts/source-serif-4-latin-700-normal.woff2'];

self.addEventListener('install', function (e) {
  e.waitUntil(caches.open(CACHE).then(function (c) { return c.addAll(FILES); }).then(function () {
    return self.skipWaiting();
  }));
});

self.addEventListener('activate', function (e) {
  e.waitUntil(caches.keys().then(function (keys) {
    return Promise.all(keys.map(function (k) { return k === CACHE ? null : caches.delete(k); }));
  }).then(function () { return self.clients.claim(); }));
});

self.addEventListener('fetch', function (e) {
  var req = e.request;
  // Only this site's own files. Database calls and other sites go straight
  // to the network, so they fail honestly when offline.
  if (req.method !== 'GET' || new URL(req.url).origin !== self.location.origin) return;

  // 'no-cache' asks GitHub whether the file changed on every load, so an edit
  // shows up straight away instead of after GitHub Pages' 10-minute cache.
  var fresh = new Request(req.url, { cache: 'no-cache', credentials: 'same-origin' });

  e.respondWith(
    fetch(fresh).then(function (res) {
      if (res.ok) {
        var copy = res.clone();
        caches.open(CACHE).then(function (c) { c.put(req.url, copy); });
      }
      return res;
    }).catch(function () {
      return caches.match(req.url).then(function (hit) {
        if (hit) return hit;
        if (req.mode === 'navigate') return caches.match('./index.html');
        return Response.error();
      });
    })
  );
});
