import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["threadContainer", "pollBuilder", "pollToggle", "submitBtn", "segment"]

  connect() {
    this.threadCount = 0
    this.pollVisible = false
  }

  addThread() {
    this.threadCount++
    const seg = document.createElement("div")
    seg.className = "thread-segment thread-segment--extra"
    seg.dataset.composeTarget = "segment"
    seg.innerHTML = `
      <div class="thread-connector"></div>
      <textarea maxlength="280" rows="2"
                placeholder="Fortführung des Threads..."
                class="thread-extra-input"
                data-action="input->compose#updateChar"></textarea>
      <div class="thread-seg-footer">
        <span class="char-counter"><span class="char-left">280</span> chars left</span>
        <button type="button" class="btn-action" data-action="click->compose#removeThread">✕</button>
      </div>
    `
    this.threadContainerTarget.appendChild(seg)
    seg.querySelector("textarea").focus()
    this.#refreshSubmitLabel()
  }

  removeThread(event) {
    event.target.closest(".thread-segment--extra").remove()
    this.threadCount = Math.max(0, this.threadCount - 1)
    this.#refreshSubmitLabel()
  }

  updateChar(event) {
    const ta = event.target
    const left = ta.closest(".thread-segment--extra")?.querySelector(".char-left")
    if (left) left.textContent = 280 - ta.value.length
  }

  togglePoll() {
    this.pollVisible = !this.pollVisible
    this.pollBuilderTarget.classList.toggle("hidden", !this.pollVisible)
    this.pollToggleTarget.classList.toggle("active", this.pollVisible)
  }

  // On submit: if thread mode, inject hidden inputs for each segment
  submitForm(event) {
    if (this.threadCount === 0) return  // normal post, no intervention needed

    event.preventDefault()
    const form = this.element

    // Collect all segment textareas in order
    const segments = [
      form.querySelector("textarea[name='post[content]']"),
      ...this.threadContainerTarget.querySelectorAll("textarea")
    ].filter(ta => ta && ta.value.trim().length > 0)

    if (segments.length === 0) return

    // Remove existing thread_contents inputs
    form.querySelectorAll("input[name='thread_contents[]']").forEach(i => i.remove())

    // Inject one hidden input per segment
    segments.forEach(ta => {
      const h = document.createElement("input")
      h.type = "hidden"
      h.name = "thread_contents[]"
      h.value = ta.value
      form.appendChild(h)
    })

    form.submit()
  }

  #refreshSubmitLabel() {
    if (!this.hasSubmitBtnTarget) return
    this.submitBtnTarget.value = this.threadCount > 0 ? "Thread posten" : "Post"

    // Attach submit handler once
    if (!this._submitBound) {
      this._submitBound = true
      this.element.addEventListener("submit", this.submitForm.bind(this))
    }
  }
}
