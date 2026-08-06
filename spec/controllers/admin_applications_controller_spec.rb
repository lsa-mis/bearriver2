require 'rails_helper'

RSpec.describe Admin::ApplicationsController, type: :controller do
  let(:admin_user) { create(:admin_user) }
  let!(:application_setting) { create(:application_setting, contest_year: 2023, active_application: true) }
  let!(:user) { create(:user) }
  let!(:application) { create(:application, user: user, conf_year: 2023, offer_status: 'not_offered') }

  before do
    sign_in admin_user
    mailer_double = double('mailer')
    allow(mailer_double).to receive(:waitlisted_offer_email).and_return(double(deliver_now: true))
    allow(LotteryMailer).to receive(:with).and_return(mailer_double)
  end

  describe '#send_offer' do
    it 'updates the application offer status' do
      expect {
        post :send_offer, params: { id: application.id }
      }.to change { application.reload.offer_status }.from('not_offered').to('registration_offered')
    end

    it 'sets the offer status date' do
      expect {
        post :send_offer, params: { id: application.id }
      }.to change { application.reload.offer_status_date }.from(nil)
    end

    it 'sets result_email_sent to true' do
      expect {
        post :send_offer, params: { id: application.id }
      }.to change { application.reload.result_email_sent }.from(false).to(true)
    end

    it 'redirects to admin application path' do
      post :send_offer, params: { id: application.id }
      expect(response).to redirect_to(admin_application_path(application))
    end
  end
end
