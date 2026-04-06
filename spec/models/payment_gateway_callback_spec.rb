require 'rails_helper'

RSpec.describe PaymentGatewayCallback, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      callback = build(:payment_gateway_callback)
      expect(callback).to be_valid
    end

    it 'is invalid with unsupported processing_status' do
      callback = build(:payment_gateway_callback, processing_status: 'unknown_status')
      expect(callback).not_to be_valid
      expect(callback.errors[:processing_status]).to include('is not included in the list')
    end
  end
end
