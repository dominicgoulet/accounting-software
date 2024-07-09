import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['tab', 'tabContent'];

  currentStepId = 0;

  previousStep() {
    this.currentStepId--;
    if (this.currentStepId < 0) this.currentStepId = 0;
    this.updateUI();
  }

  nextStep() {
    this.currentStepId++;
    if (this.currentStepId >= this.tabTargets.length - 1) this.currentStepId = this.tabTargets.length - 1;
    this.updateUI();
  }

  setStep(item) {
    this.currentStepId = parseInt(item.currentTarget.dataset.stepId);
    this.updateUI();
  }

  updateUI() {
    this.tabTargets.forEach((tab) => {
      let tabStepId = parseInt(tab.dataset.stepId);

      if (tabStepId < this.currentStepId) {
        tab.querySelector('.completed').classList.remove('hidden');
        tab.querySelector('.current').classList.add('hidden');
        tab.querySelector('.upcoming').classList.add('hidden');
      } else if (tabStepId == this.currentStepId) {
        tab.querySelector('.completed').classList.add('hidden');
        tab.querySelector('.current').classList.remove('hidden');
        tab.querySelector('.upcoming').classList.add('hidden');
      } else {
        tab.querySelector('.completed').classList.add('hidden');
        tab.querySelector('.current').classList.add('hidden');
        tab.querySelector('.upcoming').classList.remove('hidden');
      }
    });

    this.tabContentTargets.forEach((tabContent) => {
      let tabContentStepId = parseInt(tabContent.dataset.stepId);

      if (tabContentStepId === this.currentStepId) {
        tabContent.classList.remove('hidden')
      } else {
        tabContent.classList.add('hidden')
      }
    });
  }
}
