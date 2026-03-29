import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["counter", "fileName"]

  updateCount(event) {
    if (!this.hasCounterTarget) return
    const max = parseInt(event.target.getAttribute("maxlength") || 280)
    const remaining = max - event.target.value.length
    this.counterTarget.textContent = remaining
    this.counterTarget.closest(".char-counter").dataset.warn = remaining <= 20 ? "true" : "false"
  }

  fileSelected(event) {
    if (!this.hasFileNameTarget) return
    const file = event.target.files[0]
    this.fileNameTarget.textContent = file ? ` ${file.name}` : ""
  }

  submitOnEnter(event) {
    if (event.key !== "Enter" || event.shiftKey) return
    if (document.body.dataset.enterToPost !== "true") return
    event.preventDefault()
    this.element.requestSubmit()
  }
}
