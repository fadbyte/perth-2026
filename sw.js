var CACHE = 'perth-trip-v8';
var FILES = ['./', './index.html', './config.js', './manifest.json', './icons/icon-192.png', './icons/icon-512.png'];

self.addEventListener('install', function (e) {
  e.waitUntil(caches.open(CACHE).then(function (c) { return c.addAll(FILES); }).then(function () { return self.skipWaiting(); }));
});
self.addEventListener('activate', function (e) {
  e.waitUntil(caches.keys().then(function (keys) {
    return Promise.all(keys.map(function (k) { return k === CACHE ? null : caches.delete(k); }));
  }).then(function () { return self.clients.claim(); }));
});
self.addEventListener('fetch', function (e) {
  var req = e.request;
  if (req.method !== 'GET' || new URL(req.url).origin !== self.location.origin) return;
  var fresh = new Request(req.url, { cache: 'no-cache', credentials: 'same-origin' });
  e.respondWith(fetch(fresh).then(function (res) {
    if (res.ok) { var copy = res.clone(); caches.open(CACHE).then(function (c) { c.put(req.url, copy); }); }
    return res;
  }).catch(function () {
    return caches.match(req.url).then(function (hit) { if (hit) return hit; if (req.mode === 'navigate') return caches.match('./index.html'); return Response.error(); });
  }));
});
