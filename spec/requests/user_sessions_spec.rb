require 'rails_helper'

RSpec.describe 'User sessions', type: :request do
  describe 'POST /users/sign_in' do
    let(:user) { create(:user) }
    let(:email_with_null_byte) { "#{user.email}\u0000" }
    it 'sanitizes null bytes in login params and does not raise an error' do
      expect do
        post user_session_path, params: {
          user: {
            email: email_with_null_byte,
            password: user.password
          }
        }
      end.not_to raise_error

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_path)
    end

    it 'sanitizes null bytes recursively in nested params and arrays' do
      nested_params = {
        user: {
          email: "#{user.email}\u0000",
          password: "pass\u0000word123",
          metadata: {
            tags: ["alp\u0000ha", "be\u0000ta"],
            profile: {
              nickname: "ni\u0000ck"
            }
          }
        }
      }

      expect do
        post user_session_path, params: nested_params
      end.not_to raise_error

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_path)
    end

    it 'sanitizes null bytes in password before authentication' do
      expect do
        post user_session_path, params: {
          user: {
            email: user.email,
            password: "pass\u0000word123"
          }
        }
      end.not_to raise_error

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_path)
    end
  end
end
