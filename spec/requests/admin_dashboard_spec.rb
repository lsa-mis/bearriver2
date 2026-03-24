require 'rails_helper'

RSpec.describe 'Admin Dashboard', type: :request do
  let(:admin_user) { create(:admin_user) }

  describe 'GET /admin' do
    before { sign_in admin_user }

    it 'displays user email when payment has no current application' do
      application_setting = create(
        :application_setting,
        contest_year: Time.current.year,
        active_application: true
      )

      user_without_application = create(:user, email: 'noapp@example.com')

      create(
        :payment,
        user: user_without_application,
        conf_year: application_setting.contest_year
      )

      get admin_root_path

      expect(response).to be_successful
      expect(response.body).to include('noapp@example.com ( - waiting for application to be submitted)')
    end

    it 'shows special invitees with application status and account type' do
      application_setting = create(
        :application_setting,
        contest_year: Time.current.year,
        active_application: true
      )

      special_user = create(:user, email: 'special@example.com')
      scholarship_user = create(:user, email: 'scholarship@example.com')
      other_user = create(:user, email: 'other@example.com')

      create(:payment, :special, user: special_user, conf_year: application_setting.contest_year)
      create(:payment, :scholarship, user: scholarship_user, conf_year: application_setting.contest_year)
      create(:payment, user: other_user, conf_year: application_setting.contest_year)

      application = create(
        :application,
        user: special_user,
        first_name: 'Ada',
        last_name: 'Lovelace',
        conf_year: application_setting.contest_year,
        partner_registration: create(:partner_registration)
      )

      get admin_root_path

      expect(response).to be_successful
      expect(response.body).to include('Special invitees (2)')
      expect(response.body).to include('special@example.com')
      expect(response.body).to include('scholarship@example.com')
      expect(response.body).to include('Needs to submit an application to')
      expect(response.body).to include('special')
      expect(response.body).to include('scholarship')
      expect(response.body).to include("href=\"#{admin_application_path(application)}\"")
      expect(response.body).to include('Ada Lovelace')
      expect(response.body.index('scholarship@example.com')).to be < response.body.index('special@example.com')
    end
  end
end
