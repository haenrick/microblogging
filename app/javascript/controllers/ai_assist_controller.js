import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "button"]

  async improve() {
    const content = this.textareaTarget.value.trim()
    if (!content) return

    this.buttonTarget.disabled = true
    this.buttonTarget.textContent = "..."

    try {
      const response = await fetch("/ai/suggest", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ content })
      })

      const data = await response.json()
      if (data.suggestion) {
        this.textareaTarget.value = data.suggestion
        this.textareaTarget.dispatchEvent(new Event("input"))
      }
    } catch {
      // silently fail — user keeps their original text
    } finally {
      this.buttonTarget.disabled = false
      this.buttonTarget.textContent = "✦ improve"
    }
  }
}
