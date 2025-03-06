FactoryBot.define do
  factory :application do
    first_name { "John" }
    last_name { "Doe" }
    gender { "Male" }
    birth_year { 1980 }
    street { "123 Main St" }
    city { "Ann Arbor" }
    state { "MI" }
    zip { "48104" }
    country { "USA" }
    phone { "555-123-4567" }
    email { association(:user).email }
    email_confirmation { email }
    workshop_selection1 { "Workshop 1" }
    workshop_selection2 { "Workshop 2" }
    workshop_selection3 { "Workshop 3" }
    lodging_selection { "Standard" }
    conf_year { Time.current.year }
    association :user
    association :partner_registration

    trait :accepted do
      offer_status { "registration_accepted" }
    end

    trait :with_balance_due do
      offer_status { "registration_accepted" }
      # Add any other attributes needed to simulate a balance due
    end
  end
end
