require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is not valid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it 'is not valid with a duplicate email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
    end

    it 'is not valid without a password' do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
    end

    it 'is not valid with a short password' do
      user = build(:user, password: 'short', password_confirmation: 'short')
      expect(user).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many payments' do
      association = described_class.reflect_on_association(:payments)
      expect(association.macro).to eq :has_many
      expect(association.options[:dependent]).to eq :destroy
    end

    it 'has many applications' do
      association = described_class.reflect_on_association(:applications)
      expect(association.macro).to eq :has_many
      expect(association.options[:dependent]).to eq :destroy
    end
  end

  describe 'instance methods' do
    describe '#total_paid' do
      it 'returns the sum of all current conference payments' do
        user = create(:user)
        payments = double('payments')
        current_payments = double('current_payments')

        allow(user).to receive(:payments).and_return(payments)
        allow(payments).to receive(:current_conference_payments).and_return(current_payments)
        allow(current_payments).to receive(:pluck).with(:total_amount).and_return(["1000", "2000"])

        expect(user.total_paid).to eq(30.0)
      end
    end

    describe '#current_conf_application' do
      it 'returns the last active conference application' do
        user = create(:user)
        applications = double('applications')
        active_applications = double('active_applications')
        last_application = double('last_application')

        allow(user).to receive(:applications).and_return(applications)
        allow(applications).to receive(:active_conference_applications).and_return(active_applications)
        allow(active_applications).to receive(:last).and_return(last_application)

        expect(user.current_conf_application).to eq(last_application)
      end
    end

    describe '#display_name' do
      it 'returns the email' do
        user = create(:user, email: 'test@example.com')
        expect(user.display_name).to eq('test@example.com')
      end
    end
  end

  describe 'class methods' do
    describe '.ransackable_associations' do
      it 'returns the correct associations' do
        expect(User.ransackable_associations).to match_array(["applications", "payments"])
      end
    end

    describe '.ransackable_attributes' do
      it 'returns the correct attributes' do
        expected_attributes = [
          "admin", "created_at", "current_sign_in_at", "current_sign_in_ip",
          "email", "encrypted_password", "id", "id_value", "last_sign_in_at",
          "last_sign_in_ip", "remember_created_at", "reset_password_sent_at",
          "reset_password_token", "sign_in_count", "updated_at"
        ]
        expect(User.ransackable_attributes).to match_array(expected_attributes)
      end
    end
  end
end
