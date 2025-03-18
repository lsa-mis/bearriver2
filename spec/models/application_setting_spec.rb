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
  end

  describe 'scopes' do
    describe '.get_current_app_settings' do
      it 'returns the active application setting' do
        # We need to stub the max method since it's not a standard ActiveRecord method
        active_relation = double("ActiveRelation")
        allow(ApplicationSetting).to receive(:where).with("active_application = ?", true).and_return(active_relation)

        # Create a test setting
        setting = create(:application_setting, active_application: true)
        allow(active_relation).to receive(:max).and_return(setting)

        # Test the scope
        result = ApplicationSetting.get_current_app_settings

        # Verify the result
        expect(result).to eq(setting)
      end
    end

    describe '.get_current_app_year' do
      it 'returns the contest_year of the current application setting' do
        # Create a test setting
        setting = create(:application_setting, contest_year: 2023, active_application: true)

        # Stub the get_current_app_settings method
        allow(ApplicationSetting).to receive(:get_current_app_settings).and_return(setting)

        # Test the scope
        result = ApplicationSetting.get_current_app_year

        # Verify the result
        expect(result).to eq(2023)
      end
    end
  end
end
