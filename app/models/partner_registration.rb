# == Schema Information
#
# Table name: partner_registrations
#
#  id          :bigint           not null, primary key
#  description :string
#  cost        :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  active      :boolean          default(TRUE)
#
class PartnerRegistration < ApplicationRecord

  has_many :applications, dependent: :destroy

  validates :description, presence: true
  validates :cost, presence: true

  scope :active, -> { where(active: true) }

  def display_name
    "#{ self.description} ( $#{self.cost.to_i} additional fee )"
  end
end
