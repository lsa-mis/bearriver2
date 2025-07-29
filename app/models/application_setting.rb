# == Schema Information
#
# Table name: application_settings
#
#  id                                        :bigint           not null, primary key
#  opendate                                  :datetime
#  application_buffer                        :integer
#  contest_year                              :integer
#  time_zone                                 :string
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  allow_payments                            :boolean          default(FALSE)
#  active_application                        :boolean          default(FALSE), not null
#  allow_lottery_winner_emails               :boolean          default(FALSE), not null
#  allow_lottery_loser_emails                :boolean          default(FALSE), not null
#  registration_fee                          :decimal(, )      default(50.0), not null
#  lottery_buffer                            :integer          default(50), not null
#  application_open_directions               :text
#  application_closed_directions             :text
#  application_open_period                   :integer          default(48), not null
#  lottery_result                            :integer          is an Array
#  lottery_run_date                          :datetime
#  registration_acceptance_directions        :text
#  payments_directions                       :text
#  lottery_won_email                         :text
#  lottery_lost_email                        :text
#  subscription_cost                         :integer          default(0), not null
#  subscription_directions                   :text
#  special_scholarship_acceptance_directions :text
#  application_confirm_email_message         :text
#  balance_due_email_message                 :text
#  special_offer_invite_email                :text
#
class ApplicationSetting < ApplicationRecord

  validates :contest_year, presence: true, uniqueness: true
  validates :opendate, presence: true
  validates :subscription_cost, presence: { message: "enter 0 or a dollar value" }
  validates :application_buffer, presence: true
  validates :registration_fee, presence: true, numericality: true
  validates :lottery_buffer, presence: true, numericality: true
  validates :application_open_period, presence: true, numericality: { only_integer: true }

  # Deactivate other settings before saving when this one is being activated
  before_save :deactivate_other_settings, if: :activating_application?

  scope :active, -> { where(active_application: true) }

  def self.get_current_app_settings
    active.first
  end

  def self.get_current_app_year
    get_current_app_settings&.contest_year
  end

  private

  def activating_application?
    active_application? && (active_application_changed? || new_record?)
  end

  def deactivate_other_settings
    ApplicationSetting.where(active_application: true)
                     .where.not(id: id)
                     .update_all(active_application: false)
  end
end
