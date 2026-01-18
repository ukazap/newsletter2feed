import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["copyIcon", "checkIcon"]
  static values = { text: String }

  async copyToClipboard() {
    try {
      await navigator.clipboard.writeText(this.textValue)
      this.copyIconTarget.classList.add('hidden')
      this.checkIconTarget.classList.remove('hidden')
      setTimeout(() => {
        this.copyIconTarget.classList.remove('hidden')
        this.checkIconTarget.classList.add('hidden')
      }, 2000)
    } catch (err) {
      console.error('Failed to copy:', err)
    }
  }
}
