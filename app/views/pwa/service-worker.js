// fl4re Service Worker — Push Notifications only.
// No caching: HTML pages contain session-specific CSRF tokens that become stale
// when served from cache, breaking all form submissions (post, like, DM…).

self.addEventListener("install", () => self.skipWaiting());

self.addEventListener("activate", (event) => {
  // Clear any caches left over from previous SW versions.
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

// Do not intercept fetch — let every request go straight to the network.

self.addEventListener("push", (event) => {
  if (!event.data) return;
  const { title, body, path } = event.data.json();
  event.waitUntil(
    self.registration.showNotification(title, {
      body,
      icon: "/icon.png",
      badge: "/icon.png",
      data: { path }
    })
  );
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const path = event.notification.data?.path || "/";
  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if (new URL(client.url).pathname === path && "focus" in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) return clients.openWindow(path);
    })
  );
});
