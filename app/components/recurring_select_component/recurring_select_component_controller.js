import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'recurringToggle',
    'recurringOptions',
    'frequencySelector',
    'intervalLabel',
    'endRepeatSelector',
    'endRepeatDate',
    'endRepeatCount',
    'weeklyOptions',
    'monthlyOptions',
    'yearlyOptions'
  ];

  connect() {
    this.updateUI();
  }

  updateUI() {
    this.toggleRecurring();
    this.updateIntervalLabel();
    this.updateEndRepeatOptions();
  }

  toggleRecurring() {
console.log('toggleRecurring', this.recurringToggleTarget.checked)
    if (this.recurringToggleTarget.checked) {
      this.recurringOptionsTarget.classList.remove('hidden');
    } else {
      this.recurringOptionsTarget.classList.add('hidden');
    }
  }

  updateIntervalLabel() {
    this.weeklyOptionsTarget.classList.add('hidden');
    this.monthlyOptionsTarget.classList.add('hidden');
    this.yearlyOptionsTarget.classList.add('hidden');

    switch (this.frequencySelectorTarget.value) {
      case 'daily':
        this.intervalLabelTarget.innerHTML = 'days';
        break;
      case 'weekly':
        this.intervalLabelTarget.innerHTML = 'weeks';
        this.weeklyOptionsTarget.classList.remove('hidden');
        break;
      case 'monthly':
        this.intervalLabelTarget.innerHTML = 'months';
        this.monthlyOptionsTarget.classList.remove('hidden');
        break;
      case 'yearly':
        this.intervalLabelTarget.innerHTML = 'years';
        this.yearlyOptionsTarget.classList.remove('hidden');
        break;
    }
  }

  updateEndRepeatOptions() {
    this.endRepeatDateTarget.classList.add('hidden');
    this.endRepeatCountTarget.classList.add('hidden');

    switch (this.endRepeatSelectorTarget.value) {
    case 'date':
      this.endRepeatDateTarget.classList.remove('hidden');
      break;
    case 'count':
      this.endRepeatCountTarget.classList.remove('hidden');
      break;
    }
  }
}
