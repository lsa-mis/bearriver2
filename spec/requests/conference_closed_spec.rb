# frozen_string_literal: true

require 'rails_helper'

# Opt out of spec/support/application_setting_mock.rb and application_mock.rb so views use real
# ApplicationSetting rows and Application.active_conference_applications (see those files).
RSpec.describe 'Conference closed page', type: :request, real_application_settings: true do
  # Avoid multiple active ApplicationSetting rows: get_current_app_settings uses active.first (unordered).
  before { ApplicationSetting.delete_all }

  let(:conf_year) { Time.current.year }
  let(:user) { create(:user, email: "conference-closed-#{SecureRandom.hex(8)}@example.com") }
  let!(:lodging) { create(:lodging, description: 'Standard', cost: 100.0) }
  let(:partner_registration) { create(:partner_registration, cost: 75.0) }

  let!(:application_setting) do
    create(
      :application_setting,
      active_application: true,
      contest_year: conf_year,
      opendate: 1.month.ago,
      application_open_period: 48,
      application_closed_directions: '<p>UniqueClosedDirectionsHtml</p>',
      registration_fee: 50.0
    )
  end

  def create_active_application(offer_status:)
    create(
      :application,
      user: user,
      email: user.email,
      email_confirmation: user.email,
      conf_year: application_setting.contest_year,
      offer_status: offer_status,
      partner_registration: partner_registration,
      lodging_selection: 'Standard'
    )
  end

  describe 'GET /conference_closed' do
    context 'when the user is signed in with an offer and no payments' do
      before { sign_in user }

      %w[registration_offered registration_accepted].each do |status|
        it "shows the application fee payment button when offer_status is #{status}" do
          create_active_application(offer_status: status)

          get conference_closed_path

          expect(response).to be_successful
          expect(response.body).to include('To accept your offer')
          expect(response.body).to include('Pay the Application Fee')
          expect(response.body).to include('make_payment')
        end
      end
    end

    context 'when the user is signed in with an offer but already has a conference payment' do
      before { sign_in user }

      it 'shows the payments sidebar message instead of the pay button' do
        create_active_application(offer_status: 'registration_offered')
        create(
          :payment,
          :current_conference,
          user: user,
          transaction_status: '1',
          conf_year: application_setting.contest_year
        )

        get conference_closed_path

        expect(response).to be_successful
        expect(response.body).to include(
          "You may use the links in the 'Your Details' box to the right to view or manage your payments."
        )
        expect(response.body).not_to include('Pay the Application Fee')
      end
    end

    context 'when the user is signed in but offer_status is not offered or accepted' do
      before { sign_in user }

      it 'shows application_closed_directions instead of the pay button' do
        create_active_application(offer_status: 'not_offered')

        get conference_closed_path

        expect(response).to be_successful
        expect(response.body).to include('UniqueClosedDirectionsHtml')
        expect(response.body).not_to include('Pay the Application Fee')
      end
    end

    context 'when opendate is in the future (pre-open messaging)' do
      before do
        sign_in user
        application_setting.update!(opendate: 1.month.from_now)
        create_active_application(offer_status: 'registration_offered')
      end

      it 'shows the upcoming application window copy, not the pay button' do
        get conference_closed_path

        expect(response).to be_successful
        expect(response.body).to include('Thank you for your interest in Bear River.')
        expect(response.body).not_to include('Pay the Application Fee')
      end
    end

    context 'when the visitor is not signed in' do
      it 'shows application_closed_directions' do
        get conference_closed_path

        expect(response).to be_successful
        expect(response.body).to include('UniqueClosedDirectionsHtml')
        expect(response.body).not_to include('Pay the Application Fee')
      end
    end
  end
end
