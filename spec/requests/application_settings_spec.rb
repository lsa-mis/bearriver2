require 'rails_helper'

RSpec.describe 'Admin Application Settings', type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:valid_attributes) {
    {
      opendate: Time.current,
      application_buffer: 10,
      contest_year: 2023,
      time_zone: 'Eastern Time (US & Canada)',
      registration_fee: 50,
      lottery_buffer: 50,
      application_open_period: 48,
      subscription_cost: 0
    }
  }

  describe 'GET /admin/application_settings' do
    context 'when admin is not signed in' do
      it 'redirects to admin sign in page' do
        get admin_application_settings_path
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end

    context 'when admin is signed in' do
      before { sign_in admin_user }

      it 'renders a successful response' do
        ApplicationSetting.create! valid_attributes
        get admin_application_settings_path
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /admin/application_settings/:id' do
    before { sign_in admin_user }

    it 'renders a successful response' do
      application_setting = ApplicationSetting.create! valid_attributes
      get admin_application_setting_path(application_setting)
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/application_settings/:id/edit' do
    before { sign_in admin_user }

    it 'renders a successful response' do
      application_setting = ApplicationSetting.create! valid_attributes
      get edit_admin_application_setting_path(application_setting)
      expect(response).to be_successful
    end
  end

  describe 'PATCH /admin/application_settings/:id' do
    before { sign_in admin_user }

    it 'updates the requested application_setting' do
      application_setting = ApplicationSetting.create! valid_attributes
      patch admin_application_setting_path(application_setting), params: {
        application_setting: { application_buffer: 20 }
      }
      expect(application_setting.reload.application_buffer).to eq(20)
      expect(response).to redirect_to(admin_application_setting_path(application_setting))
    end

    it 're-renders edit on invalid params' do
      application_setting = ApplicationSetting.create! valid_attributes
      patch admin_application_setting_path(application_setting), params: {
        application_setting: { contest_year: nil }
      }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'DELETE /admin/application_settings/:id' do
    before { sign_in admin_user }

    it 'destroys the requested application_setting' do
      application_setting = ApplicationSetting.create! valid_attributes
      expect {
        delete admin_application_setting_path(application_setting)
      }.to change(ApplicationSetting, :count).by(-1)
      expect(response).to redirect_to(admin_application_settings_path)
    end
  end

  describe 'POST /admin/application_settings/run_lottery' do
    it 'redirects to admin sign in when not authenticated' do
      post run_lottery_admin_application_settings_path
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  describe 'POST /admin/applications/:id/send_offer' do
    let!(:application_setting) { create(:application_setting, contest_year: 2023, active_application: true) }
    let!(:user) { create(:user) }
    let!(:application) { create(:application, user: user, conf_year: 2023, offer_status: 'not_offered') }

    context 'when admin is signed in' do
      before do
        sign_in admin_user
        mailer_double = double('mailer')
        allow(mailer_double).to receive(:waitlisted_offer_email).and_return(double(deliver_now: true))
        allow(LotteryMailer).to receive(:with).and_return(mailer_double)
      end

      it 'updates the application offer status' do
        expect {
          post send_offer_admin_application_path(application)
        }.to change { application.reload.offer_status }.from('not_offered').to('registration_offered')
      end

      it 'redirects to admin application path' do
        post send_offer_admin_application_path(application)
        expect(response).to redirect_to(admin_application_path(application))
      end

      it 'does not send mail and surfaces errors when the offer update fails' do
        allow_any_instance_of(Application).to receive(:update).and_return(false)
        errors = instance_double(ActiveModel::Errors, full_messages: ['Offer status is invalid'])
        allow_any_instance_of(Application).to receive(:errors).and_return(errors)

        expect(LotteryMailer).not_to receive(:with)
        post send_offer_admin_application_path(application)

        expect(response).to redirect_to(admin_application_path(application))
        expect(flash[:alert]).to include('Could not send offer')
        expect(flash[:alert]).to include('Offer status is invalid')
        expect(application.reload.offer_status).to eq('not_offered')
      end
    end

    context 'when admin is not signed in' do
      it 'redirects to admin sign in page' do
        post send_offer_admin_application_path(application)
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end

  describe 'POST /admin/application_settings/run_lottery with pre-offers' do
    before { sign_in admin_user }

    let!(:application_setting) do
      create(:application_setting,
        contest_year: 2023,
        active_application: true,
        opendate: 2.days.ago,
        application_open_period: 24,
        lottery_result: nil
      )
    end

    let!(:pre_offer_app1) do
      app = create(:application, user: create(:user), offer_status: 'special_offer_application', result_email_sent: false)
      app.update!(conf_year: 2023)
      app
    end

    let!(:pre_offer_app2) do
      app = create(:application, user: create(:user), offer_status: 'special_offer_application', result_email_sent: false)
      app.update!(conf_year: 2023)
      app
    end

    let!(:already_sent_app) do
      app = create(:application, user: create(:user), offer_status: 'special_offer_application', result_email_sent: true)
      app.update!(conf_year: 2023)
      app
    end

    before do
      allow(Application).to receive(:active_conference_applications).and_call_original
      allow(ApplicationSetting).to receive(:get_current_app_settings).and_call_original

      mailer_double = double('mailer')
      allow(mailer_double).to receive(:pre_lottery_offer_email).and_return(double(deliver_now: true))
      allow(mailer_double).to receive(:won_lottery_email).and_return(double(deliver_now: true))
      allow(mailer_double).to receive(:lost_lottery_email).and_return(double(deliver_now: true))
      allow(LotteryMailer).to receive(:with).and_return(mailer_double)
    end

    it 'updates offer status for pre-offer applications' do
      post run_lottery_admin_application_settings_path
      expect(pre_offer_app1.reload.offer_status).to eq('registration_offered')
      expect(pre_offer_app2.reload.offer_status).to eq('registration_offered')
    end

    it 'does not send emails to applications that already had emails sent' do
      post run_lottery_admin_application_settings_path
      expect(already_sent_app.reload.offer_status).to eq('special_offer_application')
      expect(already_sent_app.result_email_sent).to be true
    end
  end

  describe 'POST /admin/application_settings/duplicate' do
    before { sign_in admin_user }

    it 'duplicates the last application setting with incremented year' do
      original_setting = ApplicationSetting.create!(valid_attributes.merge(active_application: true))

      expect {
        post duplicate_admin_application_settings_path
      }.to change(ApplicationSetting, :count).by(1)

      new_setting = ApplicationSetting.last
      expect(new_setting.contest_year).to eq(original_setting.contest_year + 1)
      expect(new_setting.active_application).to be_falsey
      expect(new_setting.lottery_result).to be_nil
      expect(response).to redirect_to(admin_application_settings_path)
    end
  end
end
