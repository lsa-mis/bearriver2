# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BalanceDueMailer, type: :mailer, real_application_settings: true, no_models_mock: true do
  let!(:settings) do
    create(
      :application_setting,
      contest_year: Time.current.year,
      active_application: true,
      balance_due_email_message: 'Please pay your balance'
    )
  end
  let(:application) { create(:application, email: 'due@example.com') }

  it 'sends outstanding_balance with contest year subject and body content' do
    mail = described_class.with(app: application).outstanding_balance

    expect(mail.to).to eq(['due@example.com'])
    expect(mail.subject).to include(settings.contest_year.to_s)
    expect(mail.subject).to include('payment due')
    expect(mail.body.encoded).to include('Please pay your balance')
  end
end
