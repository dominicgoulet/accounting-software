import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['toggle', 'content'];

  connect() {
    this.toggleContent();
  }

  toggleContent() {
    if (this.toggleTarget.checked) {
      this.contentTargets.forEach((target) => target.classList.remove('hidden'));
    } else {
      this.contentTargets.forEach((target) => target.classList.add('hidden'));
    }
  }
}
