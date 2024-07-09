import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['selectToggle', 'selectContent'];

  selectContentTargetConnected(target) {
    target.classList.add('select-close')
  }

  show() {
    this.selectContentTarget.classList.add('select-open')
    this.selectContentTarget.classList.remove('select-close')
  }

  hide(event) {
    if (event && (this.selectContentTarget.contains(event.target) || this.selectToggleTarget.contains(event.target))) {
      return;
    }

    this.selectContentTarget.classList.remove('select-open')
    this.selectContentTarget.classList.add('select-close')
  }
}
