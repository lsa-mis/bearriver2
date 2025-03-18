require 'rails_helper'

RSpec.describe PartnerRegistration, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      partner_registration = build(:partner_registration)
      expect(partner_registration).to be_valid
    end

    it 'is not valid without a description' do
      partner_registration = build(:partner_registration, description: nil)
      expect(partner_registration).not_to be_valid
      expect(partner_registration.errors[:description]).to include("can't be blank")
    end

    it 'is not valid without a cost' do
      partner_registration = build(:partner_registration, cost: nil)
      expect(partner_registration).not_to be_valid
      expect(partner_registration.errors[:cost]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'has many applications' do
      association = described_class.reflect_on_association(:applications)
      expect(association.macro).to eq :has_many
      expect(association.options[:dependent]).to eq :destroy
    end
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns partner registrations that are active' do
        # Create test data
        active_partner_registration = create(:partner_registration, active: true)
        inactive_partner_registration = create(:partner_registration, active: false)

        # Test the scope
        result = PartnerRegistration.active

        # Verify the result includes only active partner registrations
        expect(result).to include(active_partner_registration)
        expect(result).not_to include(inactive_partner_registration)
      end
    end
  end

  describe 'instance methods' do
    describe '#display_name' do
      it 'returns a formatted string with description and cost' do
        partner_registration = build(:partner_registration, description: 'No Partner', cost: 0.0)
        expect(partner_registration.display_name).to eq('No Partner ( $0 additional fee )')
      end
    end
  end
end
