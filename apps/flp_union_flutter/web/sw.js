/**
 * TAPSU Progressive Web App Service Worker
 * Designed for Flutter Web (3.22+)
 *
 * Caching Policy:
 * - CACHE: Safe static application shell assets, fonts, icons, Flutter engine binaries.
 * - NEVER CACHE: Authenticated API calls, user profile data, state/district records,
 *   issues, audit logs, uploaded documents/photos, presigned URLs, or requests with Authorization headers.
 */

const CACHE_VERSION = 'tapsu-pwa-v1';
const STATIC_CACHE = `${CACHE_VERSION}-static`;
const RUNTIME_CACHE = `${CACHE_VERSION}-runtime`;

// Pre-cached core static app shell assets
const PRECACHE_ASSETS = [
  './',
  'index.html',
  'manifest.json',
  'favicon.png',
  'icons/Icon-192.png',
  'icons/Icon-maskable-192.png',
  'icons/Icon-512.png',
  'icons/Icon-maskable-512.png',
  'assets/images/flp_union_logo.jpeg',
  'assets/images/flp_union_logo_circular.png'
];

// Install: pre-cache static assets and activate immediately
self.addEventListener('install', (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(STATIC_CACHE).then((cache) => {
      // Use map with individual catches so missing optional assets do not break SW install
      return Promise.allSettled(
        PRECACHE_ASSETS.map((url) =>
          cache.add(url).catch((err) => {
            console.warn(`[TAPSU SW] Could not pre-cache ${url}:`, err);
          })
        )
      );
    })
  );
});

// Activate: delete old cache versions and claim clients
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name.startsWith('tapsu-pwa-') && name !== STATIC_CACHE && name !== RUNTIME_CACHE)
          .map((name) => {
            console.log(`[TAPSU SW] Removing legacy cache: ${name}`);
            return caches.delete(name);
          })
      );
    }).then(() => self.clients.claim())
  );
});

/**
 * Checks whether a request should NEVER be cached.
 * Strictly protects sensitive backend APIs, authentication, uploaded media, and personal data.
 */
function isSensitiveOrBypass(request, url) {
  // Only GET requests are eligible for caching
  if (request.method !== 'GET') {
    return true;
  }

  // Never cache requests with Authorization or token headers
  if (
    request.headers.has('authorization') ||
    request.headers.has('x-access-token') ||
    request.headers.has('x-refresh-token')
  ) {
    return true;
  }

  const hostname = url.hostname.toLowerCase();
  const pathname = url.pathname.toLowerCase();

  // 1. Backend API domains & endpoints
  if (hostname.includes('taspu.in') || hostname.includes('api.')) {
    return true;
  }

  // 2. Sensitive API paths
  const sensitivePathPrefixes = [
    '/api',
    '/auth',
    '/manager',
    '/admin',
    '/issues',
    '/states',
    '/districts',
    '/engineers'
  ];
  if (sensitivePathPrefixes.some((prefix) => pathname.startsWith(prefix))) {
    return true;
  }

  // 3. Cloud storage, uploaded documents, S3, Cloudflare R2, attachments
  const sensitiveHostPatterns = [
    's3.amazonaws.com',
    'r2.cloudflarestorage.com',
    'blob.core.windows.net',
    'storage.googleapis.com'
  ];
  if (sensitiveHostPatterns.some((pattern) => hostname.includes(pattern))) {
    return true;
  }

  const sensitivePathKeywords = [
    '/uploads/',
    '/documents/',
    '/attachments/',
    '/proofs/',
    '/profile-photos/'
  ];
  if (sensitivePathKeywords.some((keyword) => pathname.includes(keyword))) {
    return true;
  }

  // 4. WebSocket, SSE, and live streams
  if (url.protocol === 'ws:' || url.protocol === 'wss:') {
    return true;
  }

  return false;
}

/**
 * Determines whether a request belongs to safe, immutable static assets
 */
function isSafeStaticAsset(url) {
  // Same-origin static assets
  if (url.origin === self.location.origin) {
    const ext = url.pathname.split('.').pop().toLowerCase();
    const staticExtensions = [
      'js',
      'wasm',
      'json',
      'css',
      'png',
      'jpg',
      'jpeg',
      'svg',
      'ico',
      'ttf',
      'otf',
      'woff',
      'woff2',
      'bin'
    ];
    return staticExtensions.includes(ext);
  }

  // Safe third-party CDNs (Google Fonts, CanvasKit binaries)
  const allowedThirdPartyDomains = [
    'fonts.googleapis.com',
    'fonts.gstatic.com',
    'www.gstatic.com'
  ];
  return allowedThirdPartyDomains.includes(url.hostname);
}

// Fetch event handler with strict security boundary
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // If request contains sensitive data or is non-GET, bypass cache completely
  if (isSensitiveOrBypass(request, url)) {
    return;
  }

  // Handle SPA navigation requests (Network-first with index.html fallback)
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then((networkResponse) => {
          if (networkResponse && networkResponse.status === 200) {
            const responseClone = networkResponse.clone();
            caches.open(STATIC_CACHE).then((cache) => cache.put('index.html', responseClone));
          }
          return networkResponse;
        })
        .catch(async () => {
          const cachedIndex = await caches.match('index.html');
          if (cachedIndex) {
            return cachedIndex;
          }
          return caches.match('./');
        })
    );
    return;
  }

  // Handle safe static assets (scripts, styles, images, fonts, wasm)
  if (isSafeStaticAsset(url)) {
    event.respondWith(
      caches.match(request).then((cachedResponse) => {
        // Return cached version if found, and update cache in background (Stale-While-Revalidate)
        const fetchPromise = fetch(request)
          .then((networkResponse) => {
            if (networkResponse && networkResponse.status === 200) {
              const responseClone = networkResponse.clone();
              caches.open(RUNTIME_CACHE).then((cache) => cache.put(request, responseClone));
            }
            return networkResponse;
          })
          .catch(() => {
            // Network failure is fine if we served cached response
            return null;
          });

        return cachedResponse || fetchPromise;
      })
    );
    return;
  }

  // Default fallback for any other safe GET request: Network first, cache fallback
  event.respondWith(
    fetch(request)
      .then((networkResponse) => {
        return networkResponse;
      })
      .catch(() => {
        return caches.match(request);
      })
  );
});
