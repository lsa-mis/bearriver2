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
    const wasPassword = this.inputTarget.type === "password"
    this.inputTarget.type = wasPassword ? "text" : "password"

    const isPlaintextVisible = this.inputTarget.type === "text"
    this.buttonTarget.setAttribute("aria-label", isPlaintextVisible ? "Hide password" : "Show password")
    this.buttonTarget.setAttribute("aria-pressed", isPlaintextVisible ? "true" : "false")

    if (this.hasIconTarget) {
      this.iconTarget.classList.toggle("bi-eye", !isPlaintextVisible)
      this.iconTarget.classList.toggle("bi-eye-slash", isPlaintextVisible)
    }
  }

  trimWhitespace() {
    this.inputTarget.value = this.inputTarget.value.trim()
  }
}
