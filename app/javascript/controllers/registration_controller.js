// app/javascript/controllers/registration_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["workshopSelection", "partnerRegistration", "partnerFirstName", "partnerLastName"]

  connect() {
    // Automatically adjust the form based on the current state when the page loads
    this.togglePartnerNameFields()
  }

  togglePartnerNameFields() {
    // Iterate over all partnerRegistrationTargets to find if any option other than 'alone' is selected
    const isPartnerAttending = this.partnerRegistrationTargets.some((input) => input.checked && !input.dataset.description.toLowerCase().includes('alone'));

    // Update the requirement state based on whether a partner is attending
    this.partnerFirstNameTarget.required = isPartnerAttending;
    this.partnerLastNameTarget.required = isPartnerAttending;

    // Optionally, show or hide fields
    this.partnerFirstNameTarget.closest('.row').style.display = isPartnerAttending ? 'flex' : 'none';
    this.partnerLastNameTarget.closest('.row').style.display = isPartnerAttending ? 'flex' : 'none';
  }
}
