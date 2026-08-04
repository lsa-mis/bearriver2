# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Payment Gateway Callbacks', type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:user) { create(:user) }
  let(:payment) { create(:payment, user: user) }
  let!(:callback) do
    create(
      :payment_gateway_callback,
      user: user,
      payment: payment,
      transaction_id: 'txn_filter_me',
      processing_status: 'recorded',
      event_type: 'receipt'
    )
  end

  describe 'authentication' do
    it 'redirects guests to admin login' do
      get admin_payment_gateway_callbacks_path
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  context 'when signed in' do
    before { sign_in admin_user }

    it 'lists callbacks' do
      get admin_payment_gateway_callbacks_path
      expect(response).to be_successful
      expect(response.body).to include('txn_filter_me')
    end

    it 'filters by transaction_id and processing_status' do
      create(:payment_gateway_callback, transaction_id: 'other_txn', processing_status: 'duplicate')
      get admin_payment_gateway_callbacks_path, params: {
        transaction_id: 'txn_filter_me',
        processing_status: 'recorded',
        event_type: 'receipt',
        user_id: user.id,
        payment_id: payment.id
      }
      expect(response).to be_successful
      expect(response.body).to include('txn_filter_me')
      expect(response.body).not_to include('other_txn')
    end

    it 'shows a callback' do
      get admin_payment_gateway_callback_path(callback)
      expect(response).to be_successful
      expect(response.body).to include('txn_filter_me')
    end
  end
end
