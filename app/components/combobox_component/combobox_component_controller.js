import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['hiddenField', 'filterValue', 'optionList', 'option', 'newItem', 'newItemName', 'modalDialog', 'returnValue', 'confirmButton', 'contextualFormFrame'];

  showOptions() {
    this.optionListTarget.classList.remove('hidden');
  }

  hideOptions(event) {
    if (event && (this.optionListTarget.contains(event.target) || this.filterValueTarget.contains(event.target))) {
      return;
    }

    this.optionListTarget.classList.add('hidden');
  }

  select(event) {
    let element = event.target;

    if (element.tagName === 'SPAN') {
      element = element.parentNode;
    }

    this.selectItem(element);
  }

  selectItem(item) {
    this.hiddenFieldTarget.value = item.dataset.id;
    this.filterValueTarget.value = item.dataset.displayName;

    this.hideOptions();
  }

  reset() {
    this.hiddenFieldTarget.value = null;
    this.filterValueTarget.value = null;
  }

  beforeFilter(e) {
    this.showOptions();

    const cancel = e && (e.code === 'Enter' || e.code === 'NumpadEnter' || e.code === 'Tab');

    if (cancel) {
      const firstOption = this.optionTargets.find((el) => !el.classList.contains('hidden'));

      if (firstOption) {
        if (e.code !== 'Tab') {
          e.preventDefault();
        }

        if (this.filterValueTarget.value.length > 0) {
          this.selectItem(firstOption);
        } else {
          this.hideOptions();
        }
      } else {
        if (e.code !== 'Tab') {
          e.preventDefault();
        }

        this.showContextualModalForm();
      }
    }

    const empty = e && e.code === 'Escape';

    if (empty) {
      this.reset();
    }
  }

  filter() {
    const pattern = this.filterValueTarget.value;

    // this was needed for something, but messes everything when you type Enter.
    // this.hiddenFieldTarget.value = null;

    if (pattern.length > 0) {
      let hasExactMatch = this.optionListTarget.querySelector('[data-filter-name="' + pattern.toLowerCase() + '"]');;
      const els = this.optionListTarget.querySelectorAll('[data-filter-name*="' + pattern.toLowerCase() + '"]');

      this.optionTargets.forEach((el) => { el.classList.add('hidden'); });

      els.forEach((el) => {
        el.classList.remove('hidden');
      });

      if (!hasExactMatch) {
        this.newItemTarget.classList.remove('hidden');
      } else {
        this.newItemTarget.classList.add('hidden');
      }

      this.newItemNameTarget.innerText = pattern;
    } else {
      this.optionTargets.forEach((el) => { el.classList.remove('hidden'); });
    }
  }

  connect() {
    let that = this;

    this.modalDialogTarget.addEventListener('close', () => {
      let val = this.modalDialogTarget.returnValue;

      if (val === 'confirm') {
        try {
          that.create(this.computeReturnValues());
        } catch (e) {
          console.log('Invalid JSON data.')
        }
      } else {
        this.reset();
        this.hideOptions();
      }
    });
  }

  showContextualModalForm() {
    this.contextualFormFrameTarget.src = this.newItemTarget.dataset.contextualFormUrl
  }

  contextualFormTargetConnected() {
    this.modalDialogTarget.showModal();
  }

  returnValueTargetConnected(el) {
    let confirmButton = this.confirmButtonTarget;
    let that = this;

    switch (this.newItemTarget.dataset.kind) {
      case 'contact':
        if (el.dataset.name === 'display_name') {
          el.value = this.filterValueTarget.value;
        }
        break;
      case 'account':
        // we could split and use the reference number from input string
        if (el.dataset.name === 'name') {
          el.value = this.filterValueTarget.value;
        }
        break;
      case 'item':
        if (el.dataset.name === 'name') {
          el.value = this.filterValueTarget.value;
        }
        break;
      case 'business_unit':
        if (el.dataset.name === 'name') {
          el.value = this.filterValueTarget.value;
        }
        break;
    }
  }

  computeReturnValues() {
    let returnValue = {};

    this.returnValueTargets.forEach((el) => {
      returnValue[el.dataset.name] = el.value;
    });

    return returnValue;
  }

  create(fields) {
    let callback;

    switch (this.newItemTarget.dataset.kind) {
      case 'contact':
        callback = this.createContact(fields);
        break;
      case 'account':
        callback = this.createAccount(fields);
        break;
      case 'productorservice':
        callback = this.createItem();
        break;
      case 'business_unit':
        callback = this.createBusinessUnit();
        break;
    }

    callback.then(response => {
      if (!response.ok) {
        throw Error(response.statusText);
      }
      return response;
    })
    .then(response => response.json())
    .then(data => {
      this.hiddenFieldTarget.value = data.id;
      this.filterValueTarget.value = data.display_name;
      this.hideOptions();
    })
  }

  createContact(fields) {
    const data = JSON.stringify({ contact: { display_name: fields.display_name }});

    return fetch('/contacts', {
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.head.querySelector('meta[name="csrf-token"]').getAttribute("content")
      },
      body: data
    });
  }

  createAccount(fields) {
    const data = JSON.stringify({ account: { name: fields.name, classification: fields.classification, reference: fields.reference }});

    return fetch('/settings/accounts', {
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.head.querySelector('meta[name="csrf-token"]').getAttribute("content")
      },
      body: data
    });
  }

  createItem(fields) {
    const data = JSON.stringify({ item: { fields }});

    return fetch('/settings/items', {
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.head.querySelector('meta[name="csrf-token"]').getAttribute("content")
      },
      body: data
    });
  }

  createBusinessUnit(fields) {
    const data = JSON.stringify({ business_unit: { fields }});

    return fetch('/settings/business_units', {
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.head.querySelector('meta[name="csrf-token"]').getAttribute("content")
      },
      body: data
    });
  }
}
