# frozen_string_literal: true

# Load with:
#   bin/rails db:seed
#
# Optional demo data:
#   CREATE_DEMO_DATA=true bin/rails db:seed
#
# Optional staging admin:
#   BEAR_RIVER_ADMIN_EMAIL=you@example.com \
#   BEAR_RIVER_ADMIN_PASSWORD='long-password' \
#   bin/rails db:seed

puts "Seeding Bear River..."

workshops = [
  ['Jerry Dennis', 'Jerry', 'Dennis'],
  ['A. Van Jordan', 'A.', 'Jordan'],
  ['Thomas Lynch', 'Thomas', 'Lynch'],
  ['Richard Tillinghast', 'Richard', 'Tillinghast'],
  ['Catherine Wing', 'Catherine', 'Wing'],
  ['Desiree Cooper', 'Desiree', 'Cooper'],
  ['V.V. (Sugi) Ganeshananthan', 'V.V.', 'Ganeshananthan'],
  ['Mardi Link', 'Mardi', 'Link'],
  ['Diane Seuss', 'Diane', 'Seuss'],
  ['Douglas Trevor', 'Douglas', 'Trevor']
]

workshops.each do |instructor, first_name, last_name|
  Workshop.find_or_create_by!(instructor:) do |workshop|
    workshop.first_name = first_name
    workshop.last_name = last_name
  end
end

lodgings = [
  ['A', 'Private Room and Private Bath', 905.0],
  ['A', 'Semi-Private Room and Shared Bath', 850.0],
  ['A', 'Bunk Room', 740.0],
  ['B', 'No Lodging', 645.0]
]

lodgings.each do |plan, description, cost|
  Lodging.find_or_create_by!(description:) do |lodging|
    lodging.plan = plan
    lodging.cost = cost
  end
end

partner_registrations = [
  [
    'My spouse/partner will not be attending the workshops, but will attend the conference AND readings',
    570.0
  ],
  [
    'My spouse/partner will not be attending the workshops, but will attend the conference',
    440.0
  ],
  [
    'I am attending the conference alone.',
    0.0
  ],
  [
    'My spouse/partner will be registering separately for the conference and workshops.',
    0.0
  ]
]

partner_registrations.each do |description, cost|
  PartnerRegistration.find_or_create_by!(description:) do |partner_registration|
    partner_registration.cost = cost
  end
end

genders = [
  ['Male', 'dude type'],
  ['Female', 'dudette type']
]

genders.each do |name, description|
  Gender.find_or_create_by!(name:) do |gender|
    gender.description = description
  end
end

application_setting = ApplicationSetting.find_or_initialize_by(
  contest_year: Time.current.year
)

application_setting.assign_attributes(
  opendate: Time.current,
  application_buffer: 50,
  registration_fee: 25,
  lottery_buffer: 50,
  application_open_period: 48,
  subscription_cost: 25,
  time_zone: 'EST',
  active_application: true,
  application_open_directions: <<~HTML.squish,
    <p>Welcome to the Bear River Application Portal!</p>
    <p>Effective for the 2022 conference date, application will now be open for a period of 48 hours. Once the 48-hour window has ended, registrants will be chosen by a random lottery system and notified via email. This email will contain directions and a link where registrants are able to pay the $25 application fee to confirm their spot in the 2022 Bear River Writers’ Conference. Payment must be received within 48 hours of notification for registrants to confirm their place in the conference. If payment is not received, the next registrant on the waitlist will be notified via email.</p>
    <p>Good luck and we hope to see you at Bear River in the Spring!</p>
  HTML
  application_closed_directions: <<~HTML.squish,
    <p>Thank you for your interest in Bear River. Unfortunately, the application is currently closed. The application period will reopen in April 2023. Please feel free to reach out with any questions to bearriver-questions@umich.edu.</p>
  HTML
  registration_acceptance_directions: <<~HTML.squish,
    <p>Dear Writer:</p>
    <p>Please log-in and pay the application fee to confirm your spot in the Bear River Writers' Conference. Again, if confirmation of payment is not received within 48 hours, we will forfeit the spot to the next person on the waitlist.</p>
    <p>Please feel free to reach out to bearriver-questions@umich.edu if you have any questions.</p>
    <p>We look forward to seeing you in the Spring!</p>
  HTML
  payments_directions: <<~HTML.squish,
    <p>Dear Writer:</p>
    <p>Thank you for your Bear River Writers' Conference Application.</p>
    <p>Half of your Bear River Writers' Conference tuition is due by March 15, 2022. The remainder is due on April 30, 2022.</p>
    <p>Lastly, this year, conference registrants may add a Michigan Quarterly Review (MQR) subscription to their application. For $25, you will receive 4 issues of MQR beginning July 1, 2022.</p>
    <p>Please feel free to reach out to bearriver-questions@umich.edu if you have any questions.</p>
  HTML
  balance_due_email_message: 'Balance due email message needs to be added.',
  subscription_directions: '<p>Subscribe to the Michigan Quarterly Review at a discounted rate.</p>',
  special_scholarship_acceptance_directions: 'Special scholarship acceptance directions need to be added.',
  special_offer_invite_email: 'Special offer invite email needs to be added.',
  application_confirm_email_message: 'Thank you for your Bear River Writers\' Conference Application. You will be notified via email if you have been accepted to the conference.',
  lottery_won_email: 'Congratulations! You’ve been selected by our randomized lottery to attend the Bear River Writers’ Conference. To confirm your spot, a $25 deposit is required at this time. You have 48 hours to make this initial deposit.',
  lottery_lost_email: 'We are sorry, but you have not been selected by our random lottery system to attend the Bear River Writers’ Conference. You have been placed on our waiting list.'
)

application_setting.save!

if ENV['CREATE_DEMO_DATA'] == 'true'
  require 'faker'

  puts "Creating demo users, applications, and payments..."

  gender_type = Gender.pluck(:name)
  workshop_type = Workshop.pluck(:instructor)
  lodging_type = Lodging.pluck(:description)
  partner_registration_ids = PartnerRegistration.pluck(:id)

  how_did_you_hear_type = [
    'Word of Mouth',
    'Magazine Advertisement',
    'Online Advertisement',
    'Newspaper Advertisement',
    'Other'
  ]

  users = 132.times.map do
    User.create!(
      email: Faker::Internet.unique.email,
      password: 'password',
      password_confirmation: 'password'
    )
  end

  users.each do |user|
    Application.create!(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      gender: gender_type.sample,
      birth_year: Faker::Number.within(range: 1940..2000),
      street: Faker::Address.street_address,
      street2: Faker::Address.secondary_address,
      city: Faker::Address.city,
      state: Faker::Address.state,
      zip: Faker::Address.zip,
      country: Faker::Address.country,
      phone: Faker::PhoneNumber.cell_phone,
      email: user.email,
      email_confirmation: user.email,
      workshop_selection1: workshop_type.sample,
      workshop_selection2: workshop_type.sample,
      workshop_selection3: workshop_type.sample,
      lodging_selection: lodging_type.sample,
      partner_first_name: Faker::Name.first_name,
      partner_last_name: Faker::Name.last_name,
      how_did_you_hear: how_did_you_hear_type.sample,
      accessibility_requirements: Faker::Lorem.sentence,
      special_lodging_request: Faker::Lorem.sentence,
      food_restrictions: Faker::Lorem.sentence,
      user_id: user.id,
      conf_year: Time.current.year,
      partner_registration_id: partner_registration_ids.sample
    )
  end

  users.sample(7).each do |user|
    date_to_use = Faker::Time.between(
      from: 3.days.ago,
      to: Time.current
    )

    Payment.create!(
      transaction_type: 'ManuallyEntered',
      transaction_status: '1',
      transaction_id: "#{date_to_use.to_i}_admin@example.com",
      total_amount: '0.0',
      transaction_date: date_to_use,
      account_type: 'scholarship',
      result_code: 'Manually Entered',
      result_message: 'This was manually entered by admin@example.com',
      user_account: nil,
      payer_identity: nil,
      timestamp: date_to_use.utc.to_i,
      transaction_hash: nil,
      user_id: user.id,
      conf_year: Time.current.year
    )

    Application.find_by(user_id: user.id)&.update!(
      offer_status: 'registration_accepted',
      offer_status_date: date_to_use
    )
  end
end

puts "Seed complete."
puts "Workshops: #{Workshop.count}"
puts "Lodgings: #{Lodging.count}"
puts "Partner registrations: #{PartnerRegistration.count}"
puts "Genders: #{Gender.count}"
puts "Application settings: #{ApplicationSetting.count}"
