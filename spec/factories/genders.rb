FactoryBot.define do
  factory :gender do
    sequence(:name) { |n| "Gender #{n}" }
    description { "A description for this gender" }
  end
end
