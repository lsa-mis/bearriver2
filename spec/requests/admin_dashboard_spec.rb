require 'rails_helper'

RSpec.describe 'Admin Dashboard', type: :request do
  let(:admin_user) { create(:admin_user) }

  describe 'GET /admin' do
    before { sign_in admin_user }

    it 'displays user email when payment has no current application' do
      application_setting = ApplicationSetting.create!(
        contest_year: Time.current.year,
        opendate: Time.current,
        subscription_cost: 0,
        application_buffer: 1,
        registration_fee: 50,
        lottery_buffer: 50,
        application_open_period: 48,
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
  end
end
