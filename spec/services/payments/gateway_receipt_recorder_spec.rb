require 'rails_helper'

RSpec.describe Payments::GatewayReceiptRecorder, type: :service do
  let(:user) { create(:user) }
  let(:application) { create(:application, user: user) }
  let(:callback_params) do
    {
      'transactionType' => 'Credit',
      'transactionStatus' => '1',
      'transactionId' => 'service_txn_123',
      'transactionTotalAmount' => '10000',
      'transactionDate' => Time.current.strftime('%m/%d/%Y'),
      'transactionAcountType' => 'registration',
      'transactionResultCode' => '0',
      'transactionResultMessage' => 'Approved',
      'orderNumber' => "#{user.email.partition('@').first}-#{user.id}",
      'timestamp' => Time.current.to_i.to_s,
      'hash' => 'valid_hash'
    }
  end

  before do
    create(:application_setting, active_application: true, contest_year: Time.current.year)
    allow(ApplicationSetting).to receive(:get_current_app_year).and_return(Time.current.year)
    application
  end

  describe '#call' do
    it 'records a new payment and creates a recorded callback audit' do
      result = described_class.new(callback_params: callback_params).call

      expect(result.status).to eq(:recorded)
      expect(Payment.find_by(transaction_id: 'service_txn_123')).to be_present

      callback = PaymentGatewayCallback.order(:id).last
      expect(callback.processing_status).to eq('recorded')
      expect(callback.user_id).to eq(user.id)
      expect(callback.payment_id).to be_present
      expect(callback.transaction_id).to eq('service_txn_123')
    end

    it 'returns duplicate and creates duplicate callback audit when transaction already exists' do
      create(:payment, transaction_id: 'service_txn_123', user: user)

      result = described_class.new(callback_params: callback_params).call

      expect(result.status).to eq(:duplicate)
      callback = PaymentGatewayCallback.order(:id).last
      expect(callback.processing_status).to eq('duplicate')
      expect(callback.user_id).to eq(user.id)
      expect(callback.payment_id).to be_nil
    end

    it 'returns forbidden and creates rejected callback audit when user cannot be resolved' do
      invalid_params = callback_params.merge('orderNumber' => 'missing-user-999999')

      result = described_class.new(callback_params: invalid_params).call

      expect(result.status).to eq(:forbidden)
      callback = PaymentGatewayCallback.order(:id).last
      expect(callback.processing_status).to eq('rejected')
      expect(callback.failure_reason).to eq('user_not_found')
      expect(callback.user_id).to be_nil
    end

    it 'returns forbidden when orderNumber does not match "<local>-<id>" format' do
      invalid_params = callback_params.merge('orderNumber' => 'not-valid')

      result = described_class.new(callback_params: invalid_params).call

      expect(result.status).to eq(:forbidden)
      expect(PaymentGatewayCallback.order(:id).last.failure_reason).to eq('invalid_order_number')
    end

    it 'returns forbidden when user id segment is not a positive integer' do
      invalid_params = callback_params.merge('orderNumber' => "#{user.email.partition('@').first}-0")

      result = described_class.new(callback_params: invalid_params).call

      expect(result.status).to eq(:forbidden)
      expect(PaymentGatewayCallback.order(:id).last.failure_reason).to eq('invalid_order_number')
    end

    it 'returns forbidden when email local part does not match orderNumber prefix' do
      invalid_params = callback_params.merge('orderNumber' => "wrongprefix-#{user.id}")

      result = described_class.new(callback_params: invalid_params).call

      expect(result.status).to eq(:forbidden)
      callback = PaymentGatewayCallback.order(:id).last
      expect(callback.failure_reason).to eq('order_number_mismatch')
      expect(callback.user_id).to be_nil
    end
  end
end
