import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { vapidKey: String }

  async connect() {
    if (!("serviceWorker" in navigator) || !("PushManager" in window)) return

    const registration = await navigator.serviceWorker.register("/service-worker.js")
    await navigator.serviceWorker.ready

    const existing = await registration.pushManager.getSubscription()
    if (existing) return  // already subscribed

    const permission = await Notification.requestPermission()
    if (permission !== "granted") return

    const subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: this.#urlBase64ToUint8Array(this.vapidKeyValue)
    })

    const { endpoint, keys: { p256dh, auth } } = subscription.toJSON()

    await fetch("/push_subscriptions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ endpoint, p256dh, auth })
    })
  }

  #urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - (base64String.length % 4)) % 4)
    const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")
    const rawData = atob(base64)
    return Uint8Array.from([...rawData].map((c) => c.charCodeAt(0)))
  }
}
