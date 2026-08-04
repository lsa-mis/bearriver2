RSpec.configure do |config|
  config.before(:each) do |example|
    # Tag with `no_models_mock: true` when specs need real Lodging/Workshop/PartnerRegistration finds.
    next if example.metadata[:no_models_mock]

    mock_lodging = double('Lodging', description: 'Standard', cost: 100.0)
    allow(Lodging).to receive(:find_by).and_return(mock_lodging)
    allow(Lodging).to receive(:find).and_return(mock_lodging)

    mock_workshop = double('Workshop', instructor: 'John Smith')
    allow(Workshop).to receive(:find).and_return(mock_workshop)

    mock_partner_registration = double(
      'PartnerRegistration',
      description: 'No Partner',
      cost: 0.0,
      display_name: 'No Partner ($0 additional fee)'
    )
    allow(PartnerRegistration).to receive(:find).and_return(mock_partner_registration)
  end
end
