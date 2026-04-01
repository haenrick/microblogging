import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
    document.body.classList.toggle("mobile-nav-open")
  }

  close() {
    this.menuTarget.classList.add("hidden")
    document.body.classList.remove("mobile-nav-open")
  }
}
