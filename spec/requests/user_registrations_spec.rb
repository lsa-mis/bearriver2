require 'rails_helper'

RSpec.describe 'User registrations', type: :request do
  describe 'POST /users' do
    let(:base_email) { "new_user_#{SecureRandom.hex(4)}@example.com" }
    let(:password) { 'password123' }

    it 'sanitizes null bytes in registration params and does not raise an error' do
      expect do
        post user_registration_path, params: {
          user: {
            email: "#{base_email}\u0000",
            password: "pass\u0000word123",
            password_confirmation: "pass\u0000word123"
          }
        }
      end.not_to raise_error

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_path)
      expect(User.exists?(email: base_email)).to be(true)
    end

    it 'sanitizes null bytes recursively for nested registration payloads' do
      nested_params = {
        user: {
          email: "#{base_email}\u0000",
          password: "pass\u0000word123",
          password_confirmation: "pass\u0000word123",
          metadata: {
            tags: ["fir\u0000st", "sec\u0000ond"],
            profile: {
              nickname: "ni\u0000ck"
            }
          }
        }
      }

      expect do
        post user_registration_path, params: nested_params
      end.not_to raise_error

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_path)
      expect(User.exists?(email: base_email)).to be(true)
    end
  end
end
