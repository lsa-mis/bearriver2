import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button", "icon"]

  connect() {
    this.handleSubmit = this.trimWhitespace.bind(this)
    this.handleToggle = this.toggleVisibility.bind(this)
    this.element.closest("form")?.addEventListener("submit", this.handleSubmit)

    if (this.hasButtonTarget) {
      this.buttonTarget.addEventListener("click", this.handleToggle)
    }
  }

  disconnect() {
    this.element.closest("form")?.removeEventListener("submit", this.handleSubmit)

    if (this.hasButtonTarget) {
      this.buttonTarget.removeEventListener("click", this.handleToggle)
    }
  }

  toggleVisibility() {
    const isHidden = this.inputTarget.type === "password"
    const isVisible = isHidden

    this.inputTarget.type = isVisible ? "text" : "password"
    this.buttonTarget.setAttribute("aria-label", isVisible ? "Hide password" : "Show password")
    this.buttonTarget.setAttribute("aria-pressed", isVisible ? "true" : "false")

    if (this.hasIconTarget) {
      this.iconTarget.classList.toggle("bi-eye", !isVisible)
      this.iconTarget.classList.toggle("bi-eye-slash", isVisible)
    }
  }

  trimWhitespace() {
    this.inputTarget.value = this.inputTarget.value.trim()
  }
}
