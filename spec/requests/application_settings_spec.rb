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
        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          sign_in admin_user
          post application_settings_path, params: {
            application_setting: { contest_year: nil } # Invalid params
          }, as: :turbo_stream # Add this to handle Turbo responses
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
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          sign_in admin_user
          application_setting = ApplicationSetting.create! valid_attributes
          patch application_setting_path(application_setting), params: {
            application_setting: { contest_year: nil } # Invalid params
          }, as: :turbo_stream # Add this to handle Turbo responses
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
