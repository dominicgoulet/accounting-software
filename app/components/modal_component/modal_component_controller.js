import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['modal'];

  hideModal() {
    let backdrop = this.modalTarget.querySelector('.modal__backdrop');
    let modal = this.modalTarget.querySelector('.modal__dialog');
    let that = this;

    modal.addEventListener('animationend', () => {
      that.element.parentElement.removeAttribute('src');
      that.modalTarget.remove();
    }, { once: true });

    backdrop.classList.add('animate-fade-out');
    modal.classList.add('animate-confirm-close-confirm-dialog');
  }

  submitEnd(e) {
    if (e.detail.success) {
      this.hideModal();
    }
  }

  closeWithKeyboard(e) {
    // if (e.code == 'Escape') {
    //   this.hideModal();
    // }
  }
}
