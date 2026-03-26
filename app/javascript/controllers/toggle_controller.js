import { Controller } from "@hotwired/stimulus"

// Toggles hidden forms within a post (reply form, edit form)
export default class extends Controller {
  static targets = ["replyForm", "editForm"]

  toggleReply() {
    this.replyFormTarget.classList.toggle("hidden")
  }

  toggleEdit() {
    this.editFormTarget.classList.toggle("hidden")
  }
}
