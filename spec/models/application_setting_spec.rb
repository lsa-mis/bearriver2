require 'rails_helper'

RSpec.describe ApplicationSetting, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      application_setting = build(:application_setting)
      expect(application_setting).to be_valid
    end

    it 'is not valid without a contest_year' do
      application_setting = build(:application_setting, contest_year: nil)
      expect(application_setting).not_to be_valid
      expect(application_setting.errors[:contest_year]).to include("can't be blank")
    end

    it 'is not valid with a duplicate contest_year' do
      create(:application_setting, contest_year: 2023)
      application_setting = build(:application_setting, contest_year: 2023)
      expect(application_setting).not_to be_valid
      expect(application_setting.errors[:contest_year]).to include("has already been taken")
    end

    it 'is not valid without an opendate' do
      application_setting = build(:application_setting, opendate: nil)
      expect(application_setting).not_to be_valid
      expect(application_setting.errors[:opendate]).to include("can't be blank")
    end

    it 'is not valid without a subscription_cost' do
      application_setting = build(:application_setting, subscription_cost: nil)
      expect(application_setting).not_to be_valid
      expect(application_setting.errors[:subscription_cost]).to include("enter 0 or a dollar value")
    end

    it 'is not valid without an application_buffer' do
      application_setting = build(:application_setting, application_buffer: nil)
      expect(application_setting).not_to be_valid
      expect(application_setting.errors[:application_buffer]).to include("can't be blank")
    end

    it 'is not valid without a registration_fee' do
      application_setting = build(:application_setting, registration_fee: nil)
      expect(application_setting).not_to be_valid
      expect(application_setting.errors[:registration_fee]).to include("can't be blank")
    end

    it 'is not valid with a non-numeric registration_fee' do
      application_setting = build(:application_setting, registration_fee: 'abc')
      expect(application_setting).not_to be_valid
      expect(application_setting.errors[:registration_fee]).to include("is not a number")
    end

    it 'is not valid without a lottery_buffer' do
      application_setting = build(:application_setting, lottery_buffer: nil)
      expect(application_setting).not_to be_valid
      expect(application_setting.errors[:lottery_buffer]).to include("can't be blank")
    end

    it 'is not valid with a non-numeric lottery_buffer' do
      application_setting = build(:application_setting, lottery_buffer: 'abc')
      expect(application_setting).not_to be_valid
      expect(application_setting.errors[:lottery_buffer]).to include("is not a number")
    end

    it 'is not valid without an application_open_period' do
      application_setting = build(:application_setting, application_open_period: nil)
      expect(application_setting).not_to be_valid
      expect(application_setting.errors[:application_open_period]).to include("can't be blank")
    end

    it 'is not valid with a non-integer application_open_period' do
      application_setting = build(:application_setting, application_open_period: 1.5)
      expect(application_setting).not_to be_valid
      expect(application_setting.errors[:application_open_period]).to include("must be an integer")
    end

    describe 'active_application behavior' do
      it 'allows creating multiple inactive application settings' do
        create(:application_setting, active_application: false, contest_year: 2023)
        second_setting = build(:application_setting, active_application: false, contest_year: 2024)
        expect(second_setting).to be_valid
      end

      it 'allows updating an existing active setting' do
        setting = create(:application_setting, active_application: true, contest_year: 2023)
        setting.contest_year = 2024
        expect(setting).to be_valid
      end
    end
  end

  describe 'callbacks' do
    describe 'deactivate_other_settings' do
      it 'deactivates other settings when one is activated' do
        # Create two inactive settings
        setting1 = create(:application_setting, active_application: false, contest_year: 2023)
        setting2 = create(:application_setting, active_application: false, contest_year: 2024)

        # Activate the first setting
        setting1.update!(active_application: true)

        # Verify the first setting is active
        expect(setting1.reload.active_application?).to be true

        # Activate the second setting - this should deactivate the first
        setting2.update!(active_application: true)

        # Verify the first setting is now inactive and second is active
        expect(setting1.reload.active_application?).to be false
        expect(setting2.reload.active_application?).to be true
      end

      it 'deactivates other settings when creating a new active setting' do
        # Create an existing active setting
        existing_setting = create(:application_setting, active_application: true, contest_year: 2023)

        # Create a new active setting
        new_setting = create(:application_setting, active_application: true, contest_year: 2024)

        # Verify the existing setting is now inactive and new setting is active
        expect(existing_setting.reload.active_application?).to be false
        expect(new_setting.reload.active_application?).to be true
      end

      it 'does not deactivate other settings when setting is deactivated' do
        # Create one active setting
        setting1 = create(:application_setting, active_application: true, contest_year: 2023)

        # Create one inactive setting
        setting2 = create(:application_setting, active_application: false, contest_year: 2024)

        # Deactivate the first setting
        setting1.update!(active_application: false)

        # Verify the second setting remains inactive
        expect(setting2.reload.active_application?).to be false
      end
    end
  end

  describe 'scopes' do
    describe '.get_current_app_settings' do
      it 'returns the active application setting' do
        # Create an active setting
        active_setting = create(:application_setting, active_application: true, contest_year: 2023)

        # Create an inactive setting
        create(:application_setting, active_application: false, contest_year: 2024)

        # Test the scope
        result = ApplicationSetting.get_current_app_settings

        # Verify the result
        expect(result).to eq(active_setting)
      end

      it 'returns nil when no active setting exists' do
        # Create only inactive settings
        create(:application_setting, active_application: false, contest_year: 2023)
        create(:application_setting, active_application: false, contest_year: 2024)

        # Test the scope
        result = ApplicationSetting.get_current_app_settings

        # Verify the result
        expect(result).to be_nil
      end
    end

    describe '.get_current_app_year' do
      it 'returns the contest_year of the current application setting' do
        # Create a test setting
        setting = create(:application_setting, contest_year: 2023, active_application: true)

        # Test the scope
        result = ApplicationSetting.get_current_app_year

        # Verify the result
        expect(result).to eq(2023)
      end

      it 'returns nil when no active setting exists' do
        # Create only inactive settings
        create(:application_setting, active_application: false, contest_year: 2023)

        # Test the scope
        result = ApplicationSetting.get_current_app_year

        # Verify the result
        expect(result).to be_nil
      end
    end
  end
end
