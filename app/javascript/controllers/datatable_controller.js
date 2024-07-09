import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['masterCheckbox', 'childrenCheckbox', 'batchActions', 'actionButton', 'identifiers'];

  connect() {
    if (this.hasMasterCheckboxTarget) {
      this.updateTargets();
    }
  }

  checkAll() {
    this.childrenCheckboxTargets.forEach((el) => {
      el.checked = this.masterCheckboxTarget.checked;
    });

    this.updateTargets();
  }

  updateTargets() {
    var atLeastOneChecked = false;
    var allChecked = true;

    this.childrenCheckboxTargets.forEach((el) => {
      if (el.checked) {
        el.parentElement.parentElement.classList.add('selected')
        atLeastOneChecked = true;
      } else {
        el.parentElement.parentElement.classList.remove('selected')
        allChecked = false;
      }
    });

    if (atLeastOneChecked) {
      this.batchActionsTarget.classList.remove('hidden');
    } else {
      this.batchActionsTarget.classList.add('hidden');
    }

    this.actionButtonTargets.forEach((btn) => {
      if (atLeastOneChecked) {
        btn.removeAttribute('disabled');
      } else {
        btn.setAttribute('disabled', 'disabled');
      }
    });

    this.masterCheckboxTarget.checked = atLeastOneChecked && allChecked;

    this.retriveIds();
  }

  retriveIds() {
    var ids = [];

    this.identifiersTargets.forEach((hidden) => {
      hidden.innerHTML = '';
    });

    this.childrenCheckboxTargets.forEach((el) => {
      if (el.checked) {
        ids.push(`<input type="hidden" name="item_ids[]" value="${el.value}" />`);
      }
    });

    this.identifiersTargets.forEach((hidden) => {
      hidden.innerHTML = ids.join('');
    });
  }
}
