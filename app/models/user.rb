# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  admin                  :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable

  has_many :payments, dependent: :destroy
  has_many :applications, dependent: :destroy

  def total_paid
    payments.current_conference_payments.pluck(:total_amount).map{ |v| v.to_f }.sum / 100
  end

  def current_conf_application
    applications.active_conference_applications.last
  end

  # def total_cost
  #   cost_lodging = Lodging.find(self.application.lodging_selection).cost.to_f
  #   cost_partner = PartnerRegistration.find(self.application.partner_registration).cost.to_f
  #   cost_lodging + cost_partner 
  # end

  def display_name
    self.email # or whatever column you want
  end
end
