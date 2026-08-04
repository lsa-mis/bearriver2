# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin AdminUsers', type: :request do
  let(:admin_user) { create(:admin_user) }
  let!(:other_admin) { create(:admin_user, email: 'other-admin@example.com') }

  describe 'authentication' do
    it 'redirects guests to admin login' do
      get admin_admin_users_path
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  context 'when signed in' do
    before { sign_in admin_user }

    describe 'GET /admin/admin_users' do
      it 'lists admin users' do
        get admin_admin_users_path
        expect(response).to be_successful
        expect(response.body).to include(other_admin.email)
      end

      it 'filters by email' do
        get admin_admin_users_path, params: { email: other_admin.email }
        expect(response).to be_successful
        expect(response.body).to include(other_admin.email)
      end
    end

    describe 'GET /admin/admin_users/:id' do
      it 'shows an admin user' do
        get admin_admin_user_path(other_admin)
        expect(response).to be_successful
        expect(response.body).to include(other_admin.email)
      end
    end

    describe 'GET /admin/admin_users/new' do
      it 'renders the form' do
        get new_admin_admin_user_path
        expect(response).to be_successful
      end
    end

    describe 'POST /admin/admin_users' do
      it 'creates an admin user' do
        expect {
          post admin_admin_users_path, params: {
            admin_user: {
              email: 'fresh-admin@example.com',
              password: 'adminpassword123',
              password_confirmation: 'adminpassword123'
            }
          }
        }.to change(AdminUser, :count).by(1)
        expect(response).to redirect_to(admin_admin_user_path(AdminUser.find_by!(email: 'fresh-admin@example.com')))
      end

      it 're-renders on invalid data' do
        expect {
          post admin_admin_users_path, params: {
            admin_user: { email: '', password: '', password_confirmation: '' }
          }
        }.not_to change(AdminUser, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe 'PATCH /admin/admin_users/:id' do
      it 'updates email without requiring password' do
        patch admin_admin_user_path(other_admin), params: {
          admin_user: { email: 'renamed-admin@example.com', password: '', password_confirmation: '' }
        }
        expect(response).to redirect_to(admin_admin_user_path(other_admin))
        expect(other_admin.reload.email).to eq('renamed-admin@example.com')
      end

      it 're-renders on invalid data' do
        patch admin_admin_user_path(other_admin), params: { admin_user: { email: '' } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe 'DELETE /admin/admin_users/:id' do
      it 'deletes the admin user' do
        expect {
          delete admin_admin_user_path(other_admin)
        }.to change(AdminUser, :count).by(-1)
        expect(response).to redirect_to(admin_admin_users_path)
      end
    end
  end
end
