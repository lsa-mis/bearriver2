# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Applications index', type: :request, no_application_mock: true do
  let(:admin_user) { create(:admin_user) }

  describe 'GET /admin/applications' do
    context 'when admin is not signed in' do
      it 'redirects to admin sign in page' do
        get admin_applications_path
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end

    context 'when admin is signed in' do
      before { sign_in admin_user }

      it 'renders successfully with default scope' do
        get admin_applications_path
        expect(response).to be_successful
      end

      it 'renders successfully with scope=all (batch data loaded)' do
        get admin_applications_path, params: { scope: 'all' }
        expect(response).to be_successful
      end

      it 'includes Balance Due column when applications exist' do
        create(:lodging, description: 'Standard')
        create(:application, lodging_selection: 'Standard')
        get admin_applications_path
        expect(response).to be_successful
        expect(response.body).to include('Balance Due')
      end
    end
  end
end
