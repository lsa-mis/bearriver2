# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Workshops', type: :request, no_models_mock: true do
  let(:admin_user) { create(:admin_user) }
  let!(:workshop) { create(:workshop, last_name: 'Smith', active: true) }

  describe 'authentication' do
    it 'redirects guests to admin login' do
      get admin_workshops_path
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  context 'when signed in' do
    before { sign_in admin_user }

    it 'lists workshops and filters' do
      create(:workshop, last_name: 'Jones', instructor: 'Jane Jones', first_name: 'Jane', active: false)
      get admin_workshops_path, params: { last_name: 'Smith', active: 'true' }
      expect(response).to be_successful
      table_last_names = response.body.scan(%r{<td>(Smith|Jones)</td>}).flatten
      expect(table_last_names).to eq(['Smith'])
    end

    it 'shows a workshop' do
      get admin_workshop_path(workshop)
      expect(response).to be_successful
      expect(response.body).to include(workshop.instructor)
    end

    it 'creates a workshop' do
      expect {
        post admin_workshops_path, params: {
          workshop: { instructor: 'Ada Lovelace', last_name: 'Lovelace', first_name: 'Ada', active: true }
        }
      }.to change(Workshop, :count).by(1)
      expect(response).to redirect_to(admin_workshop_path(Workshop.last))
    end

    it 're-renders on invalid create' do
      expect {
        post admin_workshops_path, params: { workshop: { instructor: '', last_name: '', first_name: '' } }
      }.not_to change(Workshop, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'updates a workshop' do
      patch admin_workshop_path(workshop), params: { workshop: { instructor: 'Updated Instructor' } }
      expect(response).to redirect_to(admin_workshop_path(workshop))
      expect(workshop.reload.instructor).to eq('Updated Instructor')
    end

    it 're-renders on invalid update' do
      patch admin_workshop_path(workshop), params: { workshop: { instructor: '' } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'deletes a workshop' do
      expect {
        delete admin_workshop_path(workshop)
      }.to change(Workshop, :count).by(-1)
      expect(response).to redirect_to(admin_workshops_path)
    end
  end
end
