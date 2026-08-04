RSpec.configure do |config|
  config.before(:each) do |example|
    # Tag with `real_application_settings: true` to use DB rows instead of this stub.
    next if example.metadata[:real_application_settings]
    # Controller specs set up real ApplicationSetting records for lottery/admin flows.
    next if example.metadata[:type] == :controller
    # Specs that assert ApplicationSetting.get_current_app_* behavior need the real methods.
    next if example.metadata[:described_class] == ApplicationSetting

    mock_app_setting = double(
      'ApplicationSetting',
      contest_year: Time.current.year,
      opendate: Time.current - 1.day,
      application_buffer: 100,
      active_application: true,
      allow_payments: true,
      application_open_period: 48,
      subscription_cost: 25,
      time_zone: 'Eastern Time (US & Canada)',
      balance_due_emails_last_sent_at: nil,
      lottery_result: nil,
      lottery_won_email: 'You won',
      lottery_lost_email: 'You lost',
      special_offer_invite_email: 'Special offer',
      application_confirm_email_message: 'Confirmed',
      balance_due_email_message: 'Balance due'
    )

    allow(ApplicationSetting).to receive(:get_current_app_settings).and_return(mock_app_setting)
    allow(ApplicationSetting).to receive(:get_current_app_year).and_return(mock_app_setting.contest_year)
  end
end
