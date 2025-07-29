require 'rails_helper'

RSpec.describe ApplicationSettingsController, type: :controller do
  let(:admin_user) { create(:admin_user) }

  before do
    sign_in admin_user
  end

  describe "#run_lottery" do
    context "when application period has closed" do
      let!(:application_setting) do
        create(:application_setting,
          opendate: 3.days.ago,
          application_open_period: 48,
          lottery_buffer: 5,
          lottery_result: nil,
          lottery_run_date: nil,
          active_application: true
        )
      end

      let!(:user1) { create(:user) }
      let!(:user2) { create(:user) }
      let!(:user3) { create(:user) }
      let!(:user4) { create(:user) }
      let!(:user5) { create(:user) }
      let!(:user6) { create(:user) }

      let!(:application1) { create(:application, user: user1, conf_year: 2023, offer_status: nil) }
      let!(:application2) { create(:application, user: user2, conf_year: 2023, offer_status: nil) }
      let!(:application3) { create(:application, user: user3, conf_year: 2023, offer_status: nil) }
      let!(:application4) { create(:application, user: user4, conf_year: 2023, offer_status: nil) }
      let!(:application5) { create(:application, user: user5, conf_year: 2023, offer_status: nil) }
      let!(:application6) { create(:application, user: user6, conf_year: 2023, offer_status: nil) }

      before do
        # Stub the mailer methods to avoid issues with missing email content
        mailer_double = double('mailer')
        allow(mailer_double).to receive(:won_lottery_email).and_return(double(deliver_now: true))
        allow(mailer_double).to receive(:lost_lottery_email).and_return(double(deliver_now: true))
        allow(mailer_double).to receive(:pre_lottery_offer_email).and_return(double(deliver_now: true))
        allow(LotteryMailer).to receive(:with).and_return(mailer_double)
      end

      it "runs the lottery successfully" do
        post :run_lottery

        expect(application_setting.reload.lottery_result).not_to be_nil
        expect(application_setting.reload.lottery_run_date).not_to be_nil
        expect(response).to redirect_to(admin_root_path)
        expect(flash[:notice]).to eq('The lottery was successfully run.')
      end

      it "sets lottery positions for all applications" do
        post :run_lottery

        applications = [application1, application2, application3, application4, application5, application6]
        applications.each(&:reload)

        expect(applications.map(&:lottery_position).compact.length).to eq(6)
        expect(applications.map(&:lottery_position).uniq.length).to eq(6)
      end

      it "offers registration to applications within lottery buffer" do
        post :run_lottery

        applications = [application1, application2, application3, application4, application5, application6]
        applications.each(&:reload)

        offered_applications = applications.select { |app| app.offer_status == "registration_offered" }
        expect(offered_applications.length).to eq(5)
      end

      it "sets not_offered status for applications outside lottery buffer" do
        post :run_lottery

        applications = [application1, application2, application3, application4, application5, application6]
        applications.each(&:reload)

        not_offered_applications = applications.select { |app| app.offer_status == "not_offered" }
        expect(not_offered_applications.length).to eq(1)
      end

      it "sets result_email_sent to true for all applications" do
        post :run_lottery

        applications = [application1, application2, application3, application4, application5, application6]
        applications.each(&:reload)

        expect(applications.all?(&:result_email_sent)).to be true
      end

      it "sets offer_status_date for all applications" do
        post :run_lottery

        applications = [application1, application2, application3, application4, application5, application6]
        applications.each(&:reload)

        expect(applications.all? { |app| app.offer_status_date.present? }).to be true
      end
    end

    context "when application period has not closed" do
      let!(:application_setting) do
        create(:application_setting,
          opendate: 1.hour.ago,
          application_open_period: 48,
          lottery_result: nil,
          active_application: true
        )
      end

      it "does not run the lottery" do
        post :run_lottery

        expect(application_setting.reload.lottery_result).to be_nil
        expect(response.status).to eq(204)
      end
    end

    context "when lottery has already been run" do
      let!(:application_setting) do
        create(:application_setting,
          opendate: 3.days.ago,
          application_open_period: 48,
          lottery_result: [1, 2, 3],
          lottery_run_date: 1.day.ago,
          active_application: true
        )
      end

      it "does not run the lottery again" do
        expect {
          post :run_lottery
        }.not_to change { application_setting.reload.lottery_result }

        expect(response).to redirect_to(admin_root_path)
        expect(flash[:alert]).to eq('The lottery has already been run')
      end
    end

    context "when no applications are eligible for lottery" do
      let!(:application_setting) do
        create(:application_setting,
          opendate: 3.days.ago,
          application_open_period: 48,
          lottery_buffer: 5,
          lottery_result: nil,
          active_application: true
        )
      end

      it "runs the lottery with empty results" do
        post :run_lottery

        expect(application_setting.reload.lottery_result).to eq([])
        expect(response).to redirect_to(admin_root_path)
        expect(flash[:notice]).to eq('The lottery was successfully run.')
      end
    end
  end

  describe "#send_offer" do
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
        post :send_offer, params: { id: application.id }
      }.to change { application.reload.offer_status }.from("not_offered").to("registration_offered")
    end

    it "sets the offer status date" do
      expect {
        post :send_offer, params: { id: application.id }
      }.to change { application.reload.offer_status_date }.from(nil)
    end

    it "sets result_email_sent to true" do
      expect {
        post :send_offer, params: { id: application.id }
      }.to change { application.reload.result_email_sent }.from(false).to(true)
    end

    it "redirects to admin application path" do
      post :send_offer, params: { id: application.id }
      expect(response).to redirect_to(admin_application_path(application))
    end
  end

  describe "#send_pre_lottery_selected_emails" do
    let!(:application_setting) { create(:application_setting, contest_year: 2023, active_application: true) }
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:user3) { create(:user) }

    let!(:pre_offer_app1) do
      create(:application,
        user: user1,
        conf_year: 2023,
        offer_status: "special_offer_application",
        result_email_sent: false
      )
    end

    let!(:pre_offer_app2) do
      create(:application,
        user: user2,
        conf_year: 2023,
        offer_status: "special_offer_application",
        result_email_sent: false
      )
    end

    let!(:already_sent_app) do
      create(:application,
        user: user3,
        conf_year: 2023,
        offer_status: "special_offer_application",
        result_email_sent: true
      )
    end

    before do
      # Stub the mailer methods to avoid issues with missing email content
      mailer_double = double('mailer')
      allow(mailer_double).to receive(:pre_lottery_offer_email).and_return(double(deliver_now: true))
      allow(LotteryMailer).to receive(:with).and_return(mailer_double)
    end

    it "updates offer status for pre-offer applications" do
      expect {
        controller.send(:send_pre_lottery_selected_emails)
      }.to change { pre_offer_app1.reload.offer_status }.from("special_offer_application").to("registration_offered")
        .and change { pre_offer_app2.reload.offer_status }.from("special_offer_application").to("registration_offered")
    end

    it "sets offer status date for pre-offer applications" do
      expect {
        controller.send(:send_pre_lottery_selected_emails)
      }.to change { pre_offer_app1.reload.offer_status_date }.from(nil)
        .and change { pre_offer_app2.reload.offer_status_date }.from(nil)
    end

    it "sets result_email_sent to true for pre-offer applications" do
      expect {
        controller.send(:send_pre_lottery_selected_emails)
      }.to change { pre_offer_app1.reload.result_email_sent }.from(false).to(true)
        .and change { pre_offer_app2.reload.result_email_sent }.from(false).to(true)
    end

    it "does not send emails to applications that already had emails sent" do
      controller.send(:send_pre_lottery_selected_emails)

      expect(already_sent_app.reload.offer_status).to eq("special_offer_application")
      expect(already_sent_app.result_email_sent).to be true
    end

    it "only processes applications for current conference year" do
      # Create an old application setting first
      old_setting = create(:application_setting, contest_year: 2022, active_application: false)

      # Create the old application and then update the contest year to bypass callbacks
      old_app = create(:application,
        user: create(:user),
        offer_status: "special_offer_application",
        result_email_sent: false
      )
      old_app.update_column(:conf_year, 2022)

      controller.send(:send_pre_lottery_selected_emails)

      expect(old_app.reload.offer_status).to eq("special_offer_application")
      expect(old_app.result_email_sent).to be false
    end
  end
end
