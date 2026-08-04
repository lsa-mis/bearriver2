# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Genders', type: :request do
  let(:admin_user) { create(:admin_user) }
  let!(:gender) { create(:gender, name: 'Nonbinary', description: 'NB') }

  describe 'authentication' do
    it 'redirects guests to admin login' do
      get admin_genders_path
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  context 'when signed in' do
    before { sign_in admin_user }

    it 'lists genders' do
      get admin_genders_path
      expect(response).to be_successful
      expect(response.body).to include('Nonbinary')
    end

    it 'shows a gender' do
      get admin_gender_path(gender)
      expect(response).to be_successful
      expect(response.body).to include('Nonbinary')
    end

    it 'creates a gender' do
      expect {
        post admin_genders_path, params: { gender: { name: 'Female', description: 'F' } }
      }.to change(Gender, :count).by(1)
      expect(response).to redirect_to(admin_gender_path(Gender.last))
    end

    it 'updates a gender' do
      patch admin_gender_path(gender), params: { gender: { description: 'Updated' } }
      expect(response).to redirect_to(admin_gender_path(gender))
      expect(gender.reload.description).to eq('Updated')
    end

    it 'deletes a gender' do
      expect {
        delete admin_gender_path(gender)
      }.to change(Gender, :count).by(-1)
      expect(response).to redirect_to(admin_genders_path)
    end
  end
end
