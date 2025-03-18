require 'rails_helper'

RSpec.describe Lodging, type: :model do
  describe 'validations' do
    # The Lodging model doesn't appear to have explicit validations
    # but we can still test that it can be created with valid attributes
    it 'is valid with valid attributes' do
      lodging = build(:lodging)
      expect(lodging).to be_valid
    end
  end

  describe 'instance methods' do
    describe '#display_name' do
      it 'returns a formatted string with plan, description, and cost' do
        lodging = build(:lodging, plan: 'A', description: 'Standard Room', cost: 100.0)
        expect(lodging.display_name).to eq('A - Standard Room - ( $100 )')
      end
    end
  end
end
