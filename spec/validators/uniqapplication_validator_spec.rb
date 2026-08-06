# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UniqapplicationValidator, type: :model, real_application_settings: true, no_application_mock: true, no_models_mock: true do
  let!(:settings) do
    create(:application_setting, contest_year: Time.current.year, active_application: true)
  end
  let(:user) { create(:user) }
  let(:partner_registration) { create(:partner_registration) }

  def build_application(email:, conf_year: settings.contest_year)
    build(
      :application,
      user: user,
      partner_registration: partner_registration,
      email: email,
      email_confirmation: email,
      conf_year: conf_year
    )
  end

  it 'allows the first application email for the current conference year' do
    expect(build_application(email: 'unique@example.com')).to be_valid
  end

  it 'rejects a duplicate email for the current conference year' do
    create(
      :application,
      user: create(:user),
      partner_registration: partner_registration,
      email: 'dup@example.com',
      email_confirmation: 'dup@example.com',
      conf_year: settings.contest_year
    )
    duplicate = build_application(email: 'dup@example.com')

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email]).to include('You already have completed an application for this year')
  end

  it 'allows an email that only exists in a prior conference year' do
    prior = create(
      :application,
      user: create(:user),
      partner_registration: partner_registration,
      email: 'year@example.com',
      email_confirmation: 'year@example.com'
    )
    prior.update_columns(conf_year: settings.contest_year - 1)

    expect(build_application(email: 'year@example.com')).to be_valid
  end
end
