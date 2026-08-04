# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Users', type: :request do
  let(:admin_user) { create(:admin_user) }
  let!(:user) { create(:user, email: 'member@example.com') }

  describe 'authentication' do
    it 'redirects guests to admin login' do
      get admin_users_path
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  context 'when signed in' do
    before { sign_in admin_user }

    describe 'GET /admin/users' do
      it 'lists users' do
        get admin_users_path
        expect(response).to be_successful
        expect(response.body).to include('member@example.com')
      end

      it 'filters by email' do
        create(:user, email: 'other@example.com')
        get admin_users_path, params: { email: 'member@example.com' }
        expect(response).to be_successful
        table_emails = response.body.scan(%r{<td>([^<]+@example\.com)</td>}).flatten
        expect(table_emails).to eq(['member@example.com'])
      end
    end

    describe 'GET /admin/users/:id' do
      it 'shows a user' do
        get admin_user_path(user)
        expect(response).to be_successful
        expect(response.body).to include(user.email)
      end
    end

    describe 'GET /admin/users/new' do
      it 'renders the form' do
        get new_admin_user_path
        expect(response).to be_successful
      end
    end

    describe 'POST /admin/users' do
      it 'creates a user' do
        expect {
          post admin_users_path, params: {
            user: {
              email: 'newuser@example.com',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        }.to change(User, :count).by(1)
        expect(response).to redirect_to(admin_user_path(User.find_by!(email: 'newuser@example.com')))
      end

      it 're-renders on invalid data' do
        expect {
          post admin_users_path, params: { user: { email: '', password: '', password_confirmation: '' } }
        }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe 'GET /admin/users/:id/edit' do
      it 'renders the edit form' do
        get edit_admin_user_path(user)
        expect(response).to be_successful
      end
    end

    describe 'PATCH /admin/users/:id' do
      it 'updates email without requiring password' do
        patch admin_user_path(user), params: {
          user: { email: 'updated@example.com', password: '', password_confirmation: '' }
        }
        expect(response).to redirect_to(admin_user_path(user))
        expect(user.reload.email).to eq('updated@example.com')
      end

      it 're-renders on invalid data' do
        patch admin_user_path(user), params: { user: { email: '' } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe 'DELETE /admin/users/:id' do
      it 'deletes the user' do
        expect {
          delete admin_user_path(user)
        }.to change(User, :count).by(-1)
        expect(response).to redirect_to(admin_users_path)
      end
    end
  end
end
