require 'rails_helper'

RSpec.describe "ApplicationSettings", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:valid_attributes) {
    {
      opendate: Time.current,
      application_buffer: 10,
      contest_year: 2023,
      time_zone: "Eastern Time (US & Canada)"
    }
  }
  let(:invalid_attributes) {
    {
      opendate: nil,
      application_buffer: nil,
      contest_year: nil,
      time_zone: nil
    }
  }

  describe "GET /application_settings" do
    context "when admin is not signed in" do
      it "redirects to admin sign in page" do
        get application_settings_path
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end

    context "when admin is signed in" do
      before do
        sign_in admin_user
      end

      it "renders a successful response" do
        ApplicationSetting.create! valid_attributes
        get application_settings_path
        expect(response).to be_successful
      end
    end
  end

  describe "GET /application_settings/:id" do
    context "when admin is signed in" do
      before do
        sign_in admin_user
      end

      it "renders a successful response" do
        application_setting = ApplicationSetting.create! valid_attributes
        get application_setting_path(application_setting)
        expect(response).to be_successful
      end
    end
  end

  describe "GET /application_settings/new" do
    context "when admin is signed in" do
      before do
        sign_in admin_user
      end

      it "renders a successful response" do
        get new_application_setting_path
        expect(response).to be_successful
      end
    end
  end

  describe "GET /application_settings/:id/edit" do
    context "when admin is signed in" do
      before do
        sign_in admin_user
      end

      it "renders a successful response" do
        application_setting = ApplicationSetting.create! valid_attributes
        get edit_application_setting_path(application_setting)
        expect(response).to be_successful
      end
    end
  end

  describe "POST /application_settings" do
    context "when admin is signed in" do
      before do
        sign_in admin_user
      end

      context "with valid parameters" do
        it "creates a new ApplicationSetting" do
          expect {
            post application_settings_path, params: { application_setting: valid_attributes }
          }.to change(ApplicationSetting, :count).by(1)
        end

        it "redirects to the created application_setting" do
          post application_settings_path, params: { application_setting: valid_attributes }
          expect(response).to redirect_to(application_setting_path(ApplicationSetting.last))
        end
      end

      context "with invalid parameters" do
        it "renders a turbo stream response with 200 status to display the form with errors" do
          sign_in admin_user
          post application_settings_path, params: {
            application_setting: { contest_year: nil } # Invalid params
          }, as: :turbo_stream
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include('text/vnd.turbo-stream.html')
        end

        it "renders a JSON response with 422 status when requested" do
          sign_in admin_user
          post application_settings_path, params: {
            application_setting: { contest_year: nil } # Invalid params
          }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "PATCH /application_settings/:id" do
    context "when admin is signed in" do
      before do
        sign_in admin_user
      end

      context "with valid parameters" do
        let(:new_attributes) {
          {
            opendate: 1.day.from_now,
            application_buffer: 20
          }
        }

        it "updates the requested application_setting" do
          application_setting = ApplicationSetting.create! valid_attributes
          patch application_setting_path(application_setting), params: { application_setting: new_attributes }
          application_setting.reload
          expect(application_setting.application_buffer).to eq(20)
        end

        it "redirects to the application_settings index" do
          application_setting = ApplicationSetting.create! valid_attributes
          patch application_setting_path(application_setting), params: { application_setting: new_attributes }
          application_setting.reload
          expect(response).to redirect_to(application_settings_path)
        end
      end

      context "with invalid parameters" do
        it "renders a turbo stream response with 200 status to display the form with errors" do
          sign_in admin_user
          application_setting = ApplicationSetting.create! valid_attributes
          patch application_setting_path(application_setting), params: {
            application_setting: { contest_year: nil } # Invalid params
          }, as: :turbo_stream
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include('text/vnd.turbo-stream.html')
        end

        it "renders a JSON response with 422 status when requested" do
          sign_in admin_user
          application_setting = ApplicationSetting.create! valid_attributes
          patch application_setting_path(application_setting), params: {
            application_setting: { contest_year: nil } # Invalid params
          }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "DELETE /application_settings/:id" do
    context "when admin is signed in" do
      before do
        sign_in admin_user
      end

      it "destroys the requested application_setting" do
        application_setting = ApplicationSetting.create! valid_attributes
        expect {
          delete application_setting_path(application_setting)
        }.to change(ApplicationSetting, :count).by(-1)
      end

      it "redirects to the application_settings list" do
        application_setting = ApplicationSetting.create! valid_attributes
        delete application_setting_path(application_setting)
        expect(response).to redirect_to(application_settings_url)
      end
    end
  end

  describe "POST /run_lotto" do
    context "when admin is signed in" do
      before do
        sign_in admin_user
      end
    end

    context "when admin is not signed in" do
      it "redirects to admin sign in page" do
        post run_lotto_path
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end

  describe "POST /send_offer/:id" do
    context "when admin is signed in" do
      before do
        sign_in admin_user
      end

      let!(:application_setting) { create(:application_setting, contest_year: 2023, active_application: true) }
      let!(:user) { create(:user) }
      let!(:application) { create(:application, user: user, conf_year: 2023, offer_status: "not_offered") }

      before do
        # Stub the mailer methods to avoid issues with missing email content
        mailer_double = double('mailer')
        allow(mailer_double).to receive(:waitlisted_offer_email).and_return(double(deliver_now: true))
        allow(LotteryMailer).to receive(:with).and_return(mailer_double)
      end

      it "updates the application offer status" do
        expect {
          post send_offer_path(application)
        }.to change { application.reload.offer_status }.from("not_offered").to("registration_offered")
      end

      it "sets the offer status date" do
        expect {
          post send_offer_path(application)
        }.to change { application.reload.offer_status_date }.from(nil)
      end

      it "sets result_email_sent to true" do
        expect {
          post send_offer_path(application)
        }.to change { application.reload.result_email_sent }.from(false).to(true)
      end

      it "redirects to admin application path" do
        post send_offer_path(application)
        expect(response).to redirect_to(admin_application_path(application))
      end
    end

    context "when admin is not signed in" do
      let!(:user) { create(:user) }
      let!(:application) { create(:application, user: user) }

      it "redirects to admin sign in page" do
        post send_offer_path(application)
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end

  describe "#send_pre_lottery_selected_emails" do
    context "when admin is signed in" do
      before do
        sign_in admin_user
      end

            let!(:application_setting) do
        create(:application_setting,
          contest_year: 2023,
          active_application: true,
          opendate: 2.days.ago,
          application_open_period: 24,
          lottery_result: nil
        )
      end
      let!(:user1) { create(:user) }
      let!(:user2) { create(:user) }
      let!(:user3) { create(:user) }

      let!(:pre_offer_app1) do
        app = create(:application,
          user: user1,
          offer_status: "special_offer_application",
          result_email_sent: false
        )
        app.update!(conf_year: 2023)
        app
      end

      let!(:pre_offer_app2) do
        app = create(:application,
          user: user2,
          offer_status: "special_offer_application",
          result_email_sent: false
        )
        app.update!(conf_year: 2023)
        app
      end

      let!(:already_sent_app) do
        app = create(:application,
          user: user3,
          offer_status: "special_offer_application",
          result_email_sent: true
        )
        app.update!(conf_year: 2023)
        app
      end

      # Add regular applications that will be included in the lottery
      let!(:regular_app1) do
        app = create(:application,
          user: create(:user),
          offer_status: nil
        )
        app.update!(conf_year: 2023)
        app
      end

      let!(:regular_app2) do
        app = create(:application,
          user: create(:user),
          offer_status: ""
        )
        app.update!(conf_year: 2023)
        app
      end

            before do
        # Disable the application mock for this test
        allow(Application).to receive(:active_conference_applications).and_call_original

        # Disable the application setting mock for this test
        allow(ApplicationSetting).to receive(:get_current_app_settings).and_call_original

        # Stub the mailer methods to avoid issues with missing email content
        mailer_double = double('mailer')
        allow(mailer_double).to receive(:pre_lottery_offer_email).and_return(double(deliver_now: true))
        allow(mailer_double).to receive(:won_lottery_email).and_return(double(deliver_now: true))
        allow(mailer_double).to receive(:lost_lottery_email).and_return(double(deliver_now: true))
        allow(LotteryMailer).to receive(:with).and_return(mailer_double)
      end

      it "updates offer status for pre-offer applications" do
        # The lottery runs with empty applications, so send_pre_lottery_selected_emails should still be called
        post run_lotto_path

        expect(pre_offer_app1.reload.offer_status).to eq("registration_offered")
        expect(pre_offer_app2.reload.offer_status).to eq("registration_offered")
      end

      it "sets offer status date for pre-offer applications" do
        post run_lotto_path

        expect(pre_offer_app1.reload.offer_status_date).to be_present
        expect(pre_offer_app2.reload.offer_status_date).to be_present
      end

      it "sets result_email_sent to true for pre-offer applications" do
        post run_lotto_path

        expect(pre_offer_app1.reload.result_email_sent).to be true
        expect(pre_offer_app2.reload.result_email_sent).to be true
      end

      it "does not send emails to applications that already had emails sent" do
        post run_lotto_path

        expect(already_sent_app.reload.offer_status).to eq("special_offer_application")
        expect(already_sent_app.result_email_sent).to be true
      end

      it "only processes applications for current conference year" do
        old_app = create(:application,
          user: create(:user),
          offer_status: "special_offer_application",
          result_email_sent: false
        )
        old_app.update!(conf_year: 2022) # Different year than current application setting

        post run_lotto_path

        expect(old_app.reload.offer_status).to eq("special_offer_application")
        expect(old_app.result_email_sent).to be false
      end
    end
  end

  describe "POST /duplicate_conference" do
    context "when admin is signed in" do
      before do
        sign_in admin_user
      end

      it "duplicates the last application setting with incremented year" do
        original_setting = ApplicationSetting.create!(
          opendate: Time.current,
          application_buffer: 10,
          contest_year: 2023,
          time_zone: "Eastern Time (US & Canada)",
          active_application: true
        )

        expect {
          post duplicate_conference_path
        }.to change(ApplicationSetting, :count).by(1)

        new_setting = ApplicationSetting.last
        expect(new_setting.contest_year).to eq(original_setting.contest_year + 1)
        expect(new_setting.active_application).to be_falsey
        expect(new_setting.lottery_result).to be_nil
      end

      it "redirects to admin application settings path" do
        ApplicationSetting.create! valid_attributes
        post duplicate_conference_path
        expect(response).to redirect_to(admin_application_settings_path)
      end
    end
  end
end
