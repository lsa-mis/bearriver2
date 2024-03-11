import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]

  connect() {
    this.refreshSelectOptions();
  }

  refreshSelectOptions() {
    const selectedValues = this.collectSelectedValues();
    this.selectTargets.forEach((select) => {
      this.updateOptionsVisibility(select, selectedValues);
    });
  }

  collectSelectedValues() {
    return this.selectTargets
      .map(select => select.value)
      .filter(value => value !== "");
  }

  updateOptionsVisibility(select, selectedValues) {
    Array.from(select.options).forEach(option => {
      option.hidden = selectedValues.includes(option.value) && option.value !== select.value;
    });
  }

  change() {
    this.refreshSelectOptions();
  }
}
