import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['journalEntryAmount', 'calculateFromRate', 'taxesCalculation', 'unitPrice', 'target', 'template', 'subtotal', 'salesTax', 'total', 'totalDebit', 'totalCredit', 'creditAndDebitMismatchMessage']

  static values = {
    wrapperSelector: {
      type: String,
      default: '.nested-form-wrapper'
    }
  }

  connect() {
    this.add();
    this.updateSubtotals();

    this.journalEntryAmountTargets.forEach((jeat) => {
      jeat.value = this.compute(jeat.value);
    });
  }

  add (e) {
    if (e) {
      e.preventDefault();
    }

    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
    this.targetTarget.insertAdjacentHTML('beforebegin', content)
  }

  remove (e) {
    e.preventDefault()

    const wrapper = e.target.closest(this.wrapperSelectorValue)

    if (wrapper.dataset.newRecord === 'true') {
      wrapper.remove()
    } else {
      wrapper.style.display = 'none'

      const input = wrapper.querySelector("input[name*='_destroy']")
      input.value = '1'
    }
  }

  updateTaxField(el) {
    const checkbox = el.srcElement;
    this.updateTaxFieldInner(checkbox);
  }

  updateTaxFieldInner(checkbox) {
    const rootElement = checkbox.parentNode.parentNode.parentNode;
    const textbox = rootElement.querySelector('input[type="text"]');

    if (checkbox.checked) {
      textbox.setAttribute('disabled', 'disabled');
    } else {
      textbox.removeAttribute('disabled');

      if (this.taxesCalculationTarget.value != 'exclusive') {
        this.taxesCalculationTarget.value = 'exclusive';
        this.switchTaxesCalculation();
      }
    }

    this.updateTaxes();
  }

  adjustMethod() {
    const originalMethod = this.taxesCalculationTarget.dataset.initialValue;

    if (originalMethod === 'inclusive') {
      this.subtotalTargets.forEach((s) => {
        const line = s.parentNode.parentNode.parentNode;

        const unitPriceTarget = line.querySelector('input[data-nested-form-target="unitPrice"]');
        const appliedTaxes = line.querySelector('div[data-sales-tax-picker-component--sales-tax-picker-component-target="dropdown"]').querySelectorAll('input[type="checkbox"]:checked');

        var totalTaxAmount = 0;
        var unitPrice = parseFloat(unitPriceTarget.value);

        // first pass, get the total taxe rate
        appliedTaxes.forEach((tax) => {
          const taxRate = parseFloat(tax.dataset.rate) / 100.0
          totalTaxAmount += parseFloat((unitPrice * taxRate).toFixed(2));
        });

        unitPriceTarget.value = unitPrice + totalTaxAmount;

        this.updateSubtotal(line);
      });
    }
  }

  updateTaxes() {
    var taxes = {};
    var totalAmount = 0;

    this.subtotalTargets.forEach((s) => {
      const line = s.parentNode.parentNode.parentNode;

      const quantityTarget = line.querySelector('input[data-nested-form-target="quantity"]');
      const unitPriceTarget = line.querySelector('input[data-nested-form-target="unitPrice"]');
      const subtotalTarget = line.querySelector('input[data-nested-form-target="subtotal"]');
      const appliedTaxes = line.querySelector('div[data-sales-tax-picker-component--sales-tax-picker-component-target="dropdown"]').querySelectorAll('input[type="checkbox"]:checked');

      var subtotal = parseFloat(quantityTarget.value) * parseFloat(unitPriceTarget.value);
      var totalTaxesRate = 0;
      var taxAmount = 0;

      totalAmount += subtotal;

      // first pass, get the total taxe rate (used if inclusive)
      appliedTaxes.forEach((tax) => {
        totalTaxesRate += parseFloat(tax.dataset.rate) / 100.0;
      });

      // second pass, calculate tax amount individually
      appliedTaxes.forEach((tax) => {
        const rate = parseFloat(tax.dataset.rate) / 100.0;
        var amount = 0;

        if (this.taxesCalculationTarget.value == 'exclusive') {
          amount = subtotal * rate;
        } else {
          amount = subtotal / (1 + totalTaxesRate) * rate;
        }

        taxAmount = parseFloat(amount.toFixed(2));

        if (!taxes[tax.value]) { taxes[tax.value] = 0; }
        taxes[tax.value] += taxAmount;
      });
    });

    this.salesTaxTargets.forEach((tax) => {
      const salesTaxId = tax.querySelectorAll('input[type="hidden"]')[1].value;
      const calculateFromRate = tax.querySelector('input[type="checkbox"]').checked;

      var taxAmount = taxes[salesTaxId];

      if (!calculateFromRate) {
        taxAmount = parseFloat(tax.querySelector('input[type="text"]').value);
      }

      if (taxAmount) {
        if (this.taxesCalculationTarget.value == 'exclusive') {
          totalAmount += parseFloat(taxAmount.toFixed(2));
        }

        tax.querySelector('input[type="text"]').value = taxAmount.toFixed(2);
      }
    });

    this.totalTarget.value = totalAmount.toFixed(2);
  }

  subtotalTargetConnected(target) {
    this.updateTaxes();
  }

  switchTaxesCalculation(e) {
    const newMethod = this.taxesCalculationTarget.value

    if (newMethod === 'inclusive') {
      this.calculateFromRateTargets.forEach((t) => {
        t.checked = true;
        this.updateTaxFieldInner(t);
      });
    }

    this.unitPriceTargets.forEach((s) => {
      var appliedTaxes = s.parentNode.parentNode.parentNode.querySelector('div[data-sales-tax-picker-component--sales-tax-picker-component-target="dropdown"]').querySelectorAll('input[type="checkbox"]:checked');
      var totalTaxesRate = 0;
      var actualUnitPrice = parseFloat(s.value);

      appliedTaxes.forEach((at) =>{
        totalTaxesRate += parseFloat(at.dataset.rate);
      });

      totalTaxesRate = 1 + (totalTaxesRate / 100.0);

      if (newMethod == 'exclusive') {
        s.value = parseFloat(actualUnitPrice / totalTaxesRate).toFixed(2);
      } else {
        s.value = (Math.floor(actualUnitPrice * totalTaxesRate * 100) / 100.0).toFixed(2);
      }

      this.updateSubtotal(s.parentNode.parentNode.parentNode);
    });
  }

  updateLine (e) {
    const line = e.target.parentNode.parentNode.parentNode;
    this.updateSubtotal(line);
  }

  updateSubtotals() {
    this.unitPriceTargets.forEach((s) => {
      this.updateSubtotal(s.parentNode.parentNode.parentNode);
    });
  }

  updateSubtotal(line) {
    const quantityTarget = line.querySelector('input[data-nested-form-target="quantity"]');
    const unitPriceTarget = line.querySelector('input[data-nested-form-target="unitPrice"]');
    const subtotalTarget = line.querySelector('input[data-nested-form-target="subtotal"]');

    quantityTarget.value = this.compute(quantityTarget.value);
    unitPriceTarget.value = this.compute(unitPriceTarget.value);
    subtotalTarget.value = parseFloat(quantityTarget.value * unitPriceTarget.value).toFixed(2);

    this.updateTaxes();
  }

  computeField(el) {
    el.target.value = this.compute(el.target.value);
  }

  updateTotalDebitAndCredit() {
    let totalDebit = 0;
    let totalCredit = 0;

    this.journalEntryAmountTargets.forEach((el) => {
      let value = parseFloat(el.value);
      let isDebit = el.name.indexOf('[debit]') > 0;

      if (!isNaN(value)) {
        if (isDebit) {
          totalDebit += parseFloat(el.value);
        } else {
          totalCredit += parseFloat(el.value);
        }
      }
    });

    this.totalDebitTarget.value = totalDebit.toFixed(2);
    this.totalCreditTarget.value = totalCredit.toFixed(2);

    if (totalDebit != totalCredit) {
      this.creditAndDebitMismatchMessageTarget.classList.remove('hidden');
    } else {
      this.creditAndDebitMismatchMessageTarget.classList.add('hidden');
    }
  }

  /*
   * Math functions
  */

  compute(fieldValue) {
    fieldValue = fieldValue.replace(',', '.').replace('=', '');

    fieldValue = this.evaluate(fieldValue);

    return parseFloat(fieldValue || 0).toFixed(2);
  }

  tokenize(input) {
    let scanner = 0;
    const tokens = [];

    while (scanner < input.length) {
      const char = input[scanner];

      if (/[0-9]/.test(char)) {
        let digits = '';

        while (scanner < input.length && /[0-9\.]/.test(input[scanner])) {
          digits += input[scanner++];
        }

        const number = parseFloat(digits);
        tokens.push(number);
        continue;
      }

      if (/[+\-/*()^]/.test(char)) {
        tokens.push(char);
        scanner++;
        continue;
      }

      if (char === ' ') {
        scanner++;
        continue;
      }

      return [];
    }

    return tokens;
  }

  toRPN(tokens) {
    const operators = [];
    const out = [];

    for (let i = 0; i < tokens.length; i++) {
      const token = tokens[i];

      if (typeof token === 'number') {
        out.push(token);
        continue;
      }

      if (/[+\-/*<>=^]/.test(token)) {
        while (this.shouldUnwindOperatorStack(operators, token)) {
          out.push(operators.pop());
        }
        operators.push(token);
        continue;
      }

      if (token === '(') {
        operators.push(token);
        continue;
      }

      if (token === ')') {
        while (operators.length > 0 && operators[operators.length - 1] !== '(') {
          out.push(operators.pop());
        }
        operators.pop();
        continue;
      }

      throw new Error(`Unparsed token ${token} at position ${i}`);
    }

    for (let i = operators.length - 1; i >= 0; i--) {
      out.push(operators[i]);
    }

    return out;
  }

  shouldUnwindOperatorStack(operators, nextToken) {
    const precedence = { '^': 3, '*': 2, '/': 2, '+': 1, '-': 1 };

    if (operators.length === 0) {
      return false;
    }

    const lastOperator = operators[operators.length - 1];
    return precedence[lastOperator] >= precedence[nextToken];
  }

  evalRPN(rpn) {
    const stack = [];

    for (let i = 0; i < rpn.length; i++) {
      const token = rpn[i];

      if (/[+\-/*^]/.test(token)) {
        stack.push(this.operate(token, stack));
        continue;
      }

      // token is a number
      stack.push(token);
    }

    return stack.pop();
  }

  operate(operator, stack) {
    const a = stack.pop();
    const b = stack.pop();

    switch (operator) {
      case '+':
        return b + a;
      case '-':
        return b - a;
      case '*':
        return b * a;
      case '/':
        return b / a;
      case '^':
        return Math.pow(b, a);
      default:
        throw new Error(`Invalid operator: ${operator}`);
    }
  }

  evaluate(input) {
    return this.evalRPN(this.toRPN(this.tokenize(input)));
  }
}
