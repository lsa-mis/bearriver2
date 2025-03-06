RSpec.configure do |config|
  config.before(:each, type: :request) do
    # Create a mock ApplicationSetting object
    mock_app_setting = double("ApplicationSetting",
      contest_year: Time.current.year,
      opendate: Time.current - 1.day,
      application_buffer: 100,
      active_application: true,
      allow_payments: true,
      application_open_period: 48,
      subscription_cost: 25
    )

    # Mock the ApplicationSetting.get_current_app_settings class method
    allow(ApplicationSetting).to receive(:get_current_app_settings).and_return(mock_app_setting)

    # Mock the ApplicationSetting.get_current_app_year class method
    allow(ApplicationSetting).to receive(:get_current_app_year).and_return(mock_app_setting.contest_year)
  end
end
