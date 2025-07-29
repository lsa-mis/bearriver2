FactoryBot.define do
  factory :payment do
    sequence(:transaction_id) { |n| "transaction_#{n}" }
    transaction_type { "Credit" }
    transaction_status { "settled" }
    total_amount { "10000" } # $100.00 in cents
    transaction_date { Time.current.strftime("%Y%m%d%H%M") }
    account_type { "registration" }
    result_code { "0" }
    result_message { "Approved" }
    user_account { "test_account" }
    payer_identity { "John Doe" }
    timestamp { Time.current.to_s }
    transaction_hash { "hash_#{SecureRandom.hex(10)}" }
    conf_year { Time.current.year }
    user

    trait :current_conference do
      conf_year { ApplicationSetting.get_current_app_year rescue Time.current.year }
    end

    trait :manual do
      transaction_type { "ManuallyEntered" }
      total_amount { "100.00" } # Will be converted to cents by the model
    end

    trait :scholarship do
      account_type { "scholarship" }
    end

    trait :special do
      account_type { "special" }
    end
  end
end
