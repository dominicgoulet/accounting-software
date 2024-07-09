import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['label', 'swapOn', 'swapOff'];

  isChecked() {
    let checkbox = this.labelTarget.querySelector('input[type=checkbox]');
    return checkbox.checked;
  }

  swap() {
    if (this.isChecked()) {
      this.swapOnTarget.classList.add('hidden');
      this.swapOffTarget.classList.remove('hidden');
    } else {
      this.swapOnTarget.classList.remove('hidden');
      this.swapOffTarget.classList.add('hidden');
    }
  }
}
