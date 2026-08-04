# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Partner Registrations', type: :request, no_models_mock: true do
  let(:admin_user) { create(:admin_user) }
  let!(:partner_registration) { create(:partner_registration, description: 'Bring Partner', cost: 75) }

  describe 'authentication' do
    it 'redirects guests to admin login' do
      get admin_partner_registrations_path
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  context 'when signed in' do
    before { sign_in admin_user }

    it 'lists partner registrations' do
      get admin_partner_registrations_path
      expect(response).to be_successful
      expect(response.body).to include('Bring Partner')
    end

    it 'shows a partner registration' do
      get admin_partner_registration_path(partner_registration)
      expect(response).to be_successful
      expect(response.body).to include('Bring Partner')
    end

    it 'creates a partner registration' do
      expect {
        post admin_partner_registrations_path, params: {
          partner_registration: { description: 'Solo', cost: 0, active: true }
        }
      }.to change(PartnerRegistration, :count).by(1)
      expect(response).to redirect_to(admin_partner_registration_path(PartnerRegistration.last))
    end

    it 're-renders on invalid create' do
      expect {
        post admin_partner_registrations_path, params: {
          partner_registration: { description: '', cost: nil }
        }
      }.not_to change(PartnerRegistration, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'updates a partner registration' do
      patch admin_partner_registration_path(partner_registration), params: {
        partner_registration: { description: 'Updated Partner' }
      }
      expect(response).to redirect_to(admin_partner_registration_path(partner_registration))
      expect(partner_registration.reload.description).to eq('Updated Partner')
    end

    it 're-renders on invalid update' do
      patch admin_partner_registration_path(partner_registration), params: {
        partner_registration: { description: '' }
      }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'deletes a partner registration' do
      expect {
        delete admin_partner_registration_path(partner_registration)
      }.to change(PartnerRegistration, :count).by(-1)
      expect(response).to redirect_to(admin_partner_registrations_path)
    end
  end
end
