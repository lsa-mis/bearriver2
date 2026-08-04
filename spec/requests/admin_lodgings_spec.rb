# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Lodgings', type: :request, no_models_mock: true do
  let(:admin_user) { create(:admin_user) }
  let!(:lodging) { create(:lodging, plan: 'A', description: 'Cabin', cost: 150) }

  describe 'authentication' do
    it 'redirects guests to admin login' do
      get admin_lodgings_path
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  context 'when signed in' do
    before { sign_in admin_user }

    it 'lists lodgings' do
      get admin_lodgings_path
      expect(response).to be_successful
      expect(response.body).to include('Cabin')
    end

    it 'shows a lodging' do
      get admin_lodging_path(lodging)
      expect(response).to be_successful
      expect(response.body).to include('Cabin')
    end

    it 'creates a lodging' do
      expect {
        post admin_lodgings_path, params: {
          lodging: { plan: 'B', description: 'Tent', cost: 50 }
        }
      }.to change(Lodging, :count).by(1)
      expect(response).to redirect_to(admin_lodging_path(Lodging.last))
    end

    it 'updates a lodging' do
      patch admin_lodging_path(lodging), params: { lodging: { description: 'Updated Cabin' } }
      expect(response).to redirect_to(admin_lodging_path(lodging))
      expect(lodging.reload.description).to eq('Updated Cabin')
    end

    it 'deletes a lodging' do
      expect {
        delete admin_lodging_path(lodging)
      }.to change(Lodging, :count).by(-1)
      expect(response).to redirect_to(admin_lodgings_path)
    end
  end
end
