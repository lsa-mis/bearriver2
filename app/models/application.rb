# == Schema Information
#
# Table name: applications
#
#  id                             :bigint           not null, primary key
#  first_name                     :string
#  last_name                      :string
#  gender                         :string
#  birth_year                     :integer
#  street                         :string
#  street2                        :string
#  city                           :string
#  state                          :string
#  zip                            :string
#  country                        :string
#  phone                          :string
#  email                          :string
#  email_confirmation             :string
#  workshop_selection1            :string
#  workshop_selection2            :string
#  workshop_selection3            :string
#  lodging_selection              :string
#  partner_registration_selection :string
#  partner_first_name             :string
#  partner_last_name              :string
#  how_did_you_hear               :string
#  accessibility_requirements     :text
#  special_lodging_request        :text
#  food_restrictions              :text
#  user_id                        :bigint
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  conf_year                      :integer
#  lottery_position               :integer
#  offer_status                   :string
#  result_email_sent              :boolean          default(FALSE), not null
#  offer_status_date              :datetime
#  subscription                   :boolean          default(FALSE)
#  partner_registration_id        :bigint           not null
#
class Application < ApplicationRecord
  before_create :set_contest_year

  belongs_to :partner_registration, optional: true

  validates :user_id, presence: true

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :gender, presence: true
  validates :birth_year, presence: true
  validates :street, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip, presence: true
  validates :country, presence: true
  validates :phone, presence: true
  validates :email, presence: true, uniqapplication: true
  validates :workshop_selection1, presence: true
  validates :workshop_selection2, presence: true
  validates :workshop_selection3, presence: true
  validates :lodging_selection, presence: true

  HOW_DID_YOU_HEAR = ["---", "Word of Mouth", "Magazine Advertisement", "Online Advertisement", "Newspaper Advertisement", "Other"]

  belongs_to :user

  def name
    "#{last_name}, #{first_name}"
  end

  def display_name
    "#{name} - #{email}"
  end

  def total_user_has_paid
    user.total_paid
  end

  def lodging_cost
    Lodging.find_by(description: self.lodging_selection).cost.to_f 
  end

  def partner_registration_cost
    self.partner_registration.cost.to_f
  end

  def total_cost
    lodging_cost + partner_registration_cost
  end

  def balance_due
    total_cost - total_user_has_paid
  end

  def first_workshop_instructor
    Workshop.find(workshop_selection1).instructor
  end

  def second_workshop_instructor
    Workshop.find(workshop_selection2).instructor
  end

  def third_workshop_instructor
    Workshop.find(workshop_selection3).instructor
  end

  def lodging_description
    Lodging.find(lodging_selection).description
  end

  def partner_registration_description
    PartnerRegistration.find(partner_registration_id).display_name
  end

  scope :active_conference_applications, -> { where("conf_year = ?", ApplicationSetting.get_current_app_settings.contest_year) }

  scope :entries_included_in_lottery, -> { active_conference_applications.where(offer_status: [nil, ""]) }

  scope :application_accepted, -> { active_conference_applications.where("offer_status = ?", "registration_accepted") }

  scope :application_offered, -> { active_conference_applications.where("offer_status = ? or offer_status = ?", "registration_offered", "special_offer_application") }

  scope :subscription_selected, -> { active_conference_applications.where("subscription = ?", true) }

  private

  def set_contest_year
    self.conf_year = ApplicationSetting.get_current_app_settings.contest_year
  end
end
