import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="removals"
export default class extends Controller {
  remove() {
    this.element.remove()
  }

  removeClass() {
    this.element.classList.remove(this.element.dataset.class);
  }
}
