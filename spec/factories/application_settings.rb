FactoryBot.define do
  factory :application_setting do
    sequence(:contest_year) { |n| 2023 + n }
    opendate { Time.current }
    application_buffer { 100 }
    time_zone { "Eastern Time (US & Canada)" }
    allow_payments { false }
    active_application { false }
    allow_lottery_winner_emails { false }
    allow_lottery_loser_emails { false }
    registration_fee { 50.0 }
    lottery_buffer { 50 }
    application_open_period { 48 }
    subscription_cost { 25 }
  end
end
