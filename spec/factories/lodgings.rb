FactoryBot.define do
  factory :lodging do
    plan { 'A' }
    description { "Standard" }
    cost { 100.0 }
  end
end
