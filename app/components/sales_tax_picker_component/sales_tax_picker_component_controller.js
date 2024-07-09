import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "dropdown", "filterValue", "selectedValues", "option", "optionList" ]

  showOptions() {
    this.optionListTarget.classList.remove('hidden');
  }

  hideOptions(event) {
    if (event && (this.optionListTarget.contains(event.target) || this.filterValueTarget.contains(event.target))) {
      return;
    }

    this.optionListTarget.classList.add('hidden');
  }

  connect() {
    this.updateSalesTax();
  }

  updateSalesTax() {
    var values = "";

    this.optionTargets.forEach((item) => {
      if (item.querySelector('input[type="checkbox"]').checked) {
        values += `<span class="inline-flex items-center rounded bg-green-100 px-2 py-0.5 text-xs font-medium text-green-800"><svg data-action="click->sales-tax-picker-component--sales-tax-picker-component#remove" data-id="${item.dataset.id}" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4 cursor-pointer"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" /></svg>${item.dataset.name}</span>`;
      }
    });

    this.selectedValuesTarget.innerHTML = values;
  }

  select(event) {
    event.preventDefault();

    var element = event.target;

    if (element.tagName === 'SPAN') {
      element = element.parentNode;
    }

    this.selectItem(element);
  }

  remove(e) {
    const id = e.srcElement.dataset.id;

    this.optionTargets.forEach((el) => {
      if (el.dataset.id === id) {
        this.removeItem(el);
      }
    });

    this.updateSalesTax();
  }

  removeItem(item) {
    if (item.querySelector('input[type="checkbox"]')) item.querySelector('input[type="checkbox"]').checked = false;
    if (item.querySelector('input[name*="_destroy"]')) item.querySelector('input[name*="_destroy"]').value = true;
  }

  selectItem(item) {
    item.querySelector('input[type="checkbox"]').checked = true;
    this.updateSalesTax();
    this.filterValueTarget.focus();
  }

  beforeFilter(e) {
    const select = e && (e.code === 'Enter' || e.code === 'NumpadEnter' || e.code === 'Tab');

    if (select) {
      const firstOption = this.optionTargets.find((el) => !el.classList.contains('hidden'));

      if (e.code === 'Tab') {
        if (this.filterValueTarget.value) {
          this.selectItem(firstOption);
        }

        this.filterValueTarget.value = "";
        this.hideOptions();
      } else {
        e.preventDefault();

        this.selectItem(firstOption);
        this.filterValueTarget.value = "";
      }
    }

    const remove = e && e.code === "Backspace";
    const filterIsEmpty = !this.filterValueTarget.value || this.filterValueTarget.value.length === 0;
    var lastElement = null;

    if (remove && filterIsEmpty) {
      this.optionTargets.forEach((el) => {
        if (el.querySelector('input[type="checkbox"]').checked) {
          lastElement = el;
        }
      });
    }

    if (lastElement) {
      this.removeItem(lastElement);
      this.updateSalesTax();
    }
  }

  filter() {
    const pattern = this.filterValueTarget.value;

    if (pattern.length > 0) {
      const els = document.querySelectorAll('[data-filter-name*="' + pattern.toLowerCase() + '"]');

      this.optionTargets.forEach((el) => { el.classList.add('hidden'); });
      els.forEach((el) => { el.classList.remove('hidden'); });
    } else {
      this.optionTargets.forEach((el) => { el.classList.remove('hidden'); });
    }
  }
}
