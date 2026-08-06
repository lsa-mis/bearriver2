# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppConfirmationMailer, type: :mailer, real_application_settings: true, no_models_mock: true do
  let!(:settings) do
    create(
      :application_setting,
      contest_year: Time.current.year,
      active_application: true,
      application_confirm_email_message: 'Thanks for applying'
    )
  end
  let(:application) { create(:application, email: 'confirm@example.com') }

  it 'sends application_submitted with contest year subject and body content' do
    mail = described_class.with(app: application).application_submitted

    expect(mail.to).to eq(['confirm@example.com'])
    expect(mail.subject).to include(settings.contest_year.to_s)
    expect(mail.subject).to include('application has been received')
    expect(mail.body.encoded).to include('Thanks for applying')
  end
end
