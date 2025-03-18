FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    admin { false }

    trait :admin do
      admin { true }
    end

    trait :with_payments do
      after(:create) do |user|
        create_list(:payment, 2, user: user)
      end
    end

    trait :with_applications do
      after(:create) do |user|
        create_list(:application, 2, user: user)
      end
    end
  end
end
