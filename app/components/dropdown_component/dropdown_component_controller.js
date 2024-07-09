import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['dropdownToggle', 'dropdownContent'];

  dropdownContentTargetConnected(target) {
    target.classList.add('dropdown-close')
  }

  show() {
    this.dropdownContentTarget.classList.add('dropdown-open')
    this.dropdownContentTarget.classList.remove('dropdown-close')
  }

  hide(event) {
    if (event && (this.dropdownContentTarget.contains(event.target) || this.dropdownToggleTarget.contains(event.target))) {
      return;
    }

    this.dropdownContentTarget.classList.remove('dropdown-open')
    this.dropdownContentTarget.classList.add('dropdown-close')
  }
}
