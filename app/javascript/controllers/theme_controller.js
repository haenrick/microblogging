import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  preview(event) {
    const { primary, dim, glow } = event.target.dataset
    document.documentElement.style.setProperty("--green", primary)
    document.documentElement.style.setProperty("--green-dim", dim)
    document.documentElement.style.setProperty("--green-glow", glow)
  }
}
