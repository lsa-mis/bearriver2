RSpec.configure do |config|
  config.before(:each) do
    # Mock Lodging.find_by
    mock_lodging = double("Lodging", description: "Standard", cost: 100.0)
    allow(Lodging).to receive(:find_by).and_return(mock_lodging)
    allow(Lodging).to receive(:find).and_return(mock_lodging)

    # Mock Workshop.find
    mock_workshop = double("Workshop", instructor: "John Smith")
    allow(Workshop).to receive(:find).and_return(mock_workshop)

    # Mock PartnerRegistration.find
    mock_partner_registration = double("PartnerRegistration", description: "No Partner", cost: 0.0, display_name: "No Partner ($0 additional fee)")
    allow(PartnerRegistration).to receive(:find).and_return(mock_partner_registration)

    # Mock AppConfirmationMailer
    allow_any_instance_of(AppConfirmationMailer).to receive_message_chain(:with, :application_submitted, :deliver_now)

    # Mock BalanceDueMailer
    allow_any_instance_of(BalanceDueMailer).to receive_message_chain(:with, :outstanding_balance, :deliver_now)
  end
end
