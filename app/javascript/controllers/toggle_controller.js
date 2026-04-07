import { Controller } from "@hotwired/stimulus"

// Toggles hidden forms within a post (reply form, edit form)
// and generic content panels (content target via toggle()).
export default class extends Controller {
  static targets = ["replyForm", "editForm", "content"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }

  toggleReply() {
    this.replyFormTarget.classList.toggle("hidden")
  }

  toggleEdit() {
    this.editFormTarget.classList.toggle("hidden")
  }
}
