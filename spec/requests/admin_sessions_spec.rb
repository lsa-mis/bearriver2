# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin sessions', type: :request do
  let(:admin_user) { create(:admin_user, password: 'adminpassword123', password_confirmation: 'adminpassword123') }

  describe 'GET /admin/login' do
    it 'renders the admin login page' do
      get new_admin_user_session_path
      expect(response).to be_successful
      expect(response.body).to include('Login').or include('Sign in').or include('Email')
    end
  end

  describe 'POST /admin/login' do
    it 'signs in with valid credentials and redirects to admin root' do
      post admin_user_session_path, params: {
        admin_user: { email: admin_user.email, password: 'adminpassword123' }
      }
      expect(response).to redirect_to(admin_root_path)
      follow_redirect!
      expect(response).to be_successful
    end

    it 'rejects invalid credentials' do
      post admin_user_session_path, params: {
        admin_user: { email: admin_user.email, password: 'wrong-password' }
      }
      expect(response).not_to redirect_to(admin_root_path)
      expect(response.body).to include('Invalid').or have_http_status(:unprocessable_content).or have_http_status(:ok)
    end
  end

  describe 'DELETE /admin/logout' do
    it 'signs out and redirects to admin login' do
      sign_in admin_user
      delete destroy_admin_user_session_path
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  describe 'authentication gate' do
    it 'redirects unauthenticated admin requests to login' do
      get admin_root_path
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end
end
