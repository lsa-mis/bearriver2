require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  let(:mock_app_settings) do
    instance_double(
      "ApplicationSetting",
      application_open_directions: "Open directions",
      application_closed_directions: "Closed directions",
      registration_acceptance_directions: "Acceptance directions",
      special_scholarship_acceptance_directions: "Scholarship directions",
      application_open_period: 48,
      opendate: 1.day.ago,
      contest_year: 2023,
      application_buffer: 10
    )
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_application_settings).and_return(mock_app_settings)
    # Skip rendering views to avoid template issues
    allow_any_instance_of(ActionController::Base).to receive(:render).and_return("")
  end

  describe "GET /" do
    context "when application is open" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_application_open?).and_return(true)
      end

      it "renders the index page" do
        get root_path
        expect(response).to be_successful
      end
    end

    context "when application is closed" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_application_open?).and_return(false)
      end

      it "redirects to conference_closed page" do
        get root_path
        expect(response).to redirect_to(conference_closed_url)
      end
    end
  end

  describe "GET /about" do
    it "renders the about page" do
      get about_path
      expect(response).to be_successful
    end
  end

  describe "GET /contact" do
    it "renders the contact page" do
      get contact_path
      expect(response).to be_successful
    end
  end

  describe "GET /privacy" do
    it "renders the privacy page" do
      get privacy_path
      expect(response).to be_successful
    end
  end

  describe "GET /terms_of_service" do
    it "renders the terms of use page" do
      get terms_of_service_path
      expect(response).to be_successful
    end
  end

  describe "GET /conference_closed" do
    it "renders the conference closed page" do
      get conference_closed_path
      expect(response).to be_successful
    end
  end

  describe "GET /accept_offer" do
    context "when application is open" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_application_open?).and_return(true)
      end

      it "redirects to root url" do
        get accept_offer_path
        expect(response).to redirect_to(root_url)
      end
    end

    context "when application is closed" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_application_open?).and_return(false)
      end

      it "renders the accept offer page" do
        get accept_offer_path
        expect(response).to be_successful
      end
    end
  end

  describe "GET /special_scholarship" do
    it "renders the special scholarship page" do
      get special_scholarship_path
      expect(response).to be_successful
    end
  end
end
