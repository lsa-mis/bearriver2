require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      payment = build(:payment)
      expect(payment).to be_valid
    end

    it 'is not valid without a transaction_id' do
      payment = build(:payment, transaction_id: nil)
      expect(payment).not_to be_valid
    end

    it 'is not valid with a duplicate transaction_id' do
      create(:payment, transaction_id: 'duplicate_id')
      payment = build(:payment, transaction_id: 'duplicate_id')
      expect(payment).not_to be_valid
    end

    it 'is not valid without a total_amount' do
      payment = build(:payment, total_amount: nil)
      expect(payment).not_to be_valid
    end

    context 'when transaction_type is ManuallyEntered' do
      it 'validates that total_amount is a decimal' do
        payment = build(:payment, transaction_type: 'ManuallyEntered', total_amount: 'not_a_number')
        expect(payment).not_to be_valid
        expect(payment.errors[:total_amount]).to include('must be decimal')
      end

      it 'validates that total_amount is positive' do
        payment = build(:payment, transaction_type: 'ManuallyEntered', total_amount: '-10.00')
        expect(payment).not_to be_valid
        expect(payment.errors[:total_amount]).to include('must be positive')
      end

      it 'converts the total_amount to cents before saving' do
        payment = create(:payment, transaction_type: 'ManuallyEntered', total_amount: '10.50')
        expect(payment.total_amount).to eq('1050.0')
      end
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe 'scopes' do
    describe '.current_conference_payments' do
      let(:current_year) { Time.current.year }

      before do
        allow(ApplicationSetting).to receive(:get_current_app_year).and_return(current_year)
      end

      it 'returns payments for the current conference year' do
        current_payment = create(:payment, conf_year: current_year)
        old_payment = create(:payment, conf_year: current_year - 1)

        expect(Payment.current_conference_payments).to include(current_payment)
        expect(Payment.current_conference_payments).not_to include(old_payment)
      end
    end
  end

  describe 'class methods' do
    describe '.ransackable_associations' do
      it 'returns the correct associations' do
        expect(Payment.ransackable_associations).to match_array(["user"])
      end
    end

    describe '.ransackable_attributes' do
      it 'returns the correct attributes' do
        expected_attributes = [
          "account_type", "conf_year", "created_at", "id", "id_value",
          "payer_identity", "result_code", "result_message", "timestamp",
          "total_amount", "transaction_date", "transaction_hash",
          "transaction_id", "transaction_status", "transaction_type",
          "updated_at", "user_account", "user_id"
        ]
        expect(Payment.ransackable_attributes).to match_array(expected_attributes)
      end
    end
  end
end
