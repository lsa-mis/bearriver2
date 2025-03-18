require 'rails_helper'

RSpec.describe Workshop, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      workshop = build(:workshop)
      expect(workshop).to be_valid
    end

    it 'is not valid without an instructor' do
      workshop = build(:workshop, instructor: nil)
      expect(workshop).not_to be_valid
      expect(workshop.errors[:instructor]).to include("can't be blank")
    end

    it 'is not valid without a first_name' do
      workshop = build(:workshop, first_name: nil)
      expect(workshop).not_to be_valid
      expect(workshop.errors[:first_name]).to include("can't be blank")
    end

    it 'is not valid without a last_name' do
      workshop = build(:workshop, last_name: nil)
      expect(workshop).not_to be_valid
      expect(workshop.errors[:last_name]).to include("can't be blank")
    end
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns workshops that are active' do
        # Create test data
        active_workshop = create(:workshop, active: true)
        inactive_workshop = create(:workshop, active: false)

        # Test the scope
        result = Workshop.active

        # Verify the result includes only active workshops
        expect(result).to include(active_workshop)
        expect(result).not_to include(inactive_workshop)
      end
    end
  end

  describe 'class methods' do
    describe '.ransackable_associations' do
      it 'returns an empty array' do
        expect(Workshop.ransackable_associations).to eq([])
      end
    end

    describe '.ransackable_attributes' do
      it 'returns the correct attributes' do
        expected_attributes = [
          "created_at", "first_name", "id", "active", "id_value",
          "instructor", "last_name", "updated_at"
        ]
        expect(Workshop.ransackable_attributes).to match_array(expected_attributes)
      end
    end

    describe '.order_by_lastname' do
      it 'orders workshops by last_name in ascending order' do
        expect(Workshop).to receive(:order).with('last_name asc')
        Workshop.order_by_lastname
      end
    end
  end

  describe 'instance methods' do
    describe '#display_name' do
      it 'returns the instructor name' do
        workshop = build(:workshop, instructor: 'John Smith')
        expect(workshop.display_name).to eq('John Smith')
      end
    end
  end
end
