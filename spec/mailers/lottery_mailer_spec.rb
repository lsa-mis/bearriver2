# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LotteryMailer, type: :mailer, real_application_settings: true, no_models_mock: true do
  let!(:settings) do
    create(
      :application_setting,
      contest_year: Time.current.year,
      active_application: true,
      lottery_won_email: 'Won body',
      lottery_lost_email: 'Lost body',
      special_offer_invite_email: 'Offer body'
    )
  end
  let(:application) { create(:application, email: 'writer@example.com', first_name: 'Ada', last_name: 'Lovelace') }

  it 'sends won_lottery_email' do
    mail = described_class.with(application: application).won_lottery_email
    expect(mail.to).to eq(['writer@example.com'])
    expect(mail.subject).to include(settings.contest_year.to_s)
    expect(mail.body.encoded).to include('Won body').or include('Ada')
  end

  it 'sends pre_lottery_offer_email' do
    mail = described_class.with(application: application).pre_lottery_offer_email
    expect(mail.to).to eq(['writer@example.com'])
    expect(mail.body.encoded).to include('Offer body').or include('Ada')
  end

  it 'sends waitlisted_offer_email' do
    mail = described_class.with(application: application).waitlisted_offer_email
    expect(mail.to).to eq(['writer@example.com'])
    expect(mail.subject).to include(settings.contest_year.to_s)
  end

  it 'sends lost_lottery_email' do
    mail = described_class.with(application: application).lost_lottery_email
    expect(mail.to).to eq(['writer@example.com'])
    expect(mail.subject).to include('lottery result')
    expect(mail.body.encoded).to include('Lost body').or include(settings.contest_year.to_s)
  end
end
