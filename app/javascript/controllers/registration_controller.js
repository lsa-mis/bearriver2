import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["partnerRegistration", "partnerFirstName", "partnerLastName"]

  connect() {
    this.updatePartnerFieldsVisibility();
  }

  updatePartnerFieldsVisibility() {
    const isPartnerAttending = this.isPartnerSelected();
    this.setFieldsRequirement(isPartnerAttending);
    this.toggleFieldsVisibility(isPartnerAttending);
  }

  isPartnerSelected() {
    return this.partnerRegistrationTargets.some(input => 
      input.checked && !input.dataset.description.toLowerCase().includes('alone')
    );
  }

  setFieldsRequirement(requirement) {
    [this.partnerFirstNameTarget, this.partnerLastNameTarget].forEach(field => {
      field.required = requirement;
    });
  }

  toggleFieldsVisibility(visible) {
    const displayValue = visible ? 'flex' : 'none';
    [this.partnerFirstNameTarget, this.partnerLastNameTarget].forEach(field => {
      field.closest('.row').style.display = displayValue;
    });
  }
}
