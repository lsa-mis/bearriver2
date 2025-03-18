require 'rails_helper'

RSpec.describe Gender, type: :model do
  describe 'validations' do
    # The Gender model doesn't appear to have explicit validations
    # but we can still test that it can be created with valid attributes
    it 'is valid with valid attributes' do
      gender = build(:gender)
      expect(gender).to be_valid
    end
  end

  describe 'instance methods' do
    describe '#display_name' do
      it 'returns the name of the gender' do
        gender = build(:gender, name: 'Non-binary')
        expect(gender.display_name).to eq('Non-binary')
      end
    end
  end
end
