FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "admin#{n}@example.com" }
    password { "adminpassword123" }
    password_confirmation { "adminpassword123" }
  end
end
