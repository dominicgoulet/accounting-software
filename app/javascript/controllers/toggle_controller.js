import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['trigger', 'toggleContent'];

  toggle(event) {
    let icons = this.triggerTarget.querySelectorAll('svg')

    if (this.toggleContentTarget.classList.contains('hidden')) {
      this.toggleContentTarget.classList.remove('hidden')

      icons[0].classList.add('hidden');
      icons[1].classList.remove('hidden');
    } else {
      this.toggleContentTarget.classList.add('hidden')

      icons[0].classList.remove('hidden');
      icons[1].classList.add('hidden');
    }
  }
}
