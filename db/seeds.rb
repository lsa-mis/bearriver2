# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# On production use: bin/rails db:seed RAILS_ENV=production

Workshop.create!([
  {
    instructor: 'Jerry Dennis',
    first_name: 'Jerry',
    last_name: 'Dennis'
  },
  {
    instructor: 'A. Van Jordan',
    first_name: 'A.',
    last_name: 'Jordan'
  },
  {
    instructor: 'Thomas Lynch',
    first_name: 'Thomas',
    last_name: 'Lynch'
  },
  {
    instructor: 'Richard Tillinghast',
    first_name: 'Richard',
    last_name: 'Tillinghast'
  },
  {
    instructor: 'Catherine Wing',
    first_name: 'Catherine',
    last_name: 'Wing'
  },
  {
    instructor: 'Desiree Cooper',
    first_name: 'Desiree',
    last_name: 'Cooper'
  },
  {
    instructor: 'V.V. (Sugi) Ganeshananthan',
    first_name: 'V.V.',
    last_name: 'Ganeshananthan'
  },
  {
    instructor: 'Mardi Link',
    first_name: 'Mardi',
    last_name: 'Link'
  },
  {
    instructor: 'Diane Seuss',
    first_name: 'Diane',
    last_name: 'Seuss'
  },
  {
    instructor: 'Douglas Trevor',
    first_name: 'Douglas',
    last_name: 'Trevor'
  }
])

Lodging.create!([
  {
    plan: 'A',
    description: 'Private Room and Private Bath',
    cost: '905.0'
  },
  {
    plan: 'A',
    description: 'Semi-Private Room and Shared Bath',
    cost: '850.0'
  },
  {
    plan: 'A',
    description: 'Bunk Room',
    cost: '740.0'
  },
  {
    plan: 'B',
    description: 'No Lodging',
    cost: '645.0'
  }
])

PartnerRegistration.create!([
  {
    description: 'My spouse/partner will not be attending the workshops, but will attend the conference AND readings',
    cost: '570.0'
  },
  {
    description: 'My spouse/partner will not be attending the workshops, but will attend the conference',
    cost: '440.0'
  },
  {
    description: 'I am attending the conference alone.',
    cost: '0.0'
  },
  {
    description: 'My spouse/partner will be registering separately for the conference and workshops.',
    cost: '0.0'
  }
])

ApplicationSetting.create!([
  {
    opendate: Time.now,
    application_buffer: 50,
    registration_fee: 25,
    lottery_buffer: 50,
    application_open_period: 48,
    contest_year: Time.now.year,
    subscription_cost: 25,
    time_zone: "EST",
    active_application: true,
    application_open_directions: "<p>Welcome to the Bear River Application Portal!</p> <p>Effective for the 2022 conference date, application will now be open for a period of 48 hours. Once the 48-hour window has ended, registrants will be chosen by a random lottery system and notified via email. This email will contain directions and a link where registrants are able to pay the $25 application fee to confirm their spot in the 2022 Bear River Writers’ Conference. Payment must be received within 48 hours of notification for registrants to confirm their place in the conference. If payment is not received, the next registrant on the waitlist will be notified via email.</p> <p>Good luck and we hope to see you at Bear River in the Spring!</p>",
    application_closed_directions: "<p>Thank you for your interest in Bear River. Unfortunately, the application is currently closed. The application period will reopen in April 2023. Please feel free to reach out with any questions to bearriver-questions@umich.edu.</p> <p></p>",
    registration_acceptance_directions: "<p>Dear Writer:</p> <p>Please log-in and pay the application fee to confirm your spot in the Bear River Writers' Conference. Again, if confirmation of payment is not received within 48 hours, we will forfeit the spot to the next person on the waitlist.</p> <p>Please feel free to reach out to bearriver-questions@umich.edu if you have any questions.</p> <p>We look forward to seeing you in the Spring!</p>",
    payments_directions: "<p>Dear Writer:</p> <p>Thank you for your Bear River Writers' Conference Application.</p> <p>Half of your Bear River Writers' Conference tuition is due by March 15, 2022. The remainder is due on April 30, 2022.</p> <p>Lastly, this year, conference registrants may add a Michigan Quarterly Review (MQR) subscription to their application. For $25 (a discounted rate for Bear River participants), you will receive 4 issues of MQR beginning July 1, 2022. Michigan Quarterly Review is an interdisciplinary and international literary journal, combining distinctive voices in poetry, fiction, and nonfiction, as well as works in translation. Writers are able to submit to MQR for publication.</p> <p>Please feel free to reach out to bearriver-questions@umich.edu if you have any questions.</p>",
    balance_due_email_message:  "Balance due email message needs to be added.",
    subscription_directions: "<p>Subscribe to the Michigan Quarterly Review at a discounted rate.</p>",
    special_scholarship_acceptance_directions: "Special scholarship acceptance directions need to be added.",
    special_offer_invite_email: "Special offer invite email needs to be added.",
    application_confirm_email_message: "Thank you for your Bear River Writers' Conference Application. You will be notified via email if you have been accepted to the conference.",
    lottery_won_email: "Congratulations! You’ve been selected by our randomized lottery to attend the 2022 Bear River Writers’ Conference. To confirm your spot, a $25 deposit is required at this time. You have 48 hours to make this initial deposit, after which your spot will be forfeited to the next person on the waitlist. After payment is received your spot will be officially confirmed. We’ll be in touch with you at the beginning of March with your room and workshop assignments at which point you’ll be directed to make final payments. If you have any questions, please email bearriver-questions@umich.edu. We look forward to seeing you in the Spring!",
    lottery_lost_email: "We are sorry, but you have not been selected by our random lottery system to attend the 2022 Bear River Writers’ Conference. You have been placed on our waiting list. If a spot opens up, we will notify you immediately via email. We thank you for your interest in Bear River. If you have any questions, please email bearriver-questions@umich.edu."
  }
])

Gender.create!([
  {
    name: "Male",
    description: "dude type"
  },
  {
    name: "Female",
    description: "dudette type"
  }
])

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

# create 132 users user the faker gem
gender_type = ["Male", "Female"]
workshop_type = ["Jerry Dennis", "A. Van Jordan", "Thomas Lynch", "Richard Tillinghast", "Catherine Wing", "Desiree Cooper", "V.V. (Sugi) Ganeshananthan", "Mardi Link", "Diane Seuss", "Douglas Trevor"]
lodging_type = ["No Lodging", "Bunk Room", "Semi-Private Room and Shared Bath", "Private Room and Private Bath"]
how_did_you_hear_type = ["Word of Mouth", "Magazine Advertisement", "Online Advertisement", "Newspaper Advertisement", "Other"]

132.times do
  user = User.create!(email: Faker::Internet.email, password: 'password', password_confirmation: 'password')
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
    conf_year: Time.now.year,
    partner_registration_id: Faker::Number.within(range: 1..4)
  )
end

# create 7 payments using random user ids
7.times do
  date_to_use = Faker::Time.between(from: DateTime.now - 3, to: DateTime.now)
  user = User.find(Faker::Number.within(range: 1..132))
  Payment.create!(
    transaction_type: "ManuallyEntered",
    transaction_status: "1",
    transaction_id: "#{date_to_use}_admin@example.com",
    total_amount: "0.0",
    transaction_date: date_to_use,
    account_type: "scholarship",
    result_code: "Manually Entered",
    result_message: "This was manually entered by admin@example.com",
    user_account: nil,
    payer_identity: nil,
    timestamp: date_to_use.utc.to_i,
    transaction_hash: nil,
    user_id: user.id,
    conf_year: Time.now.year
  )
  Application.find_by(user_id: user.id).update!(offer_status: "registration_accepted", offer_status_date: date_to_use)
end