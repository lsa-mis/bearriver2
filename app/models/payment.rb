# == Schema Information
#
# Table name: payments
#
#  id                 :bigint           not null, primary key
#  transaction_type   :string
#  transaction_status :string
#  transaction_id     :string
#  total_amount       :string
#  transaction_date   :string
#  account_type       :string
#  result_code        :string
#  result_message     :string
#  user_account       :string
#  payer_identity     :string
#  timestamp          :string
#  transaction_hash   :string
#  user_id            :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  conf_year          :integer
#
class Payment < ApplicationRecord
  validates :transaction_id, presence: true, uniqueness: true
  validates :total_amount, presence: true
  belongs_to :user
  validate :manual_payment_decimal
  before_save :check_manual_amount

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["account_type", "conf_year", "created_at", "id", "id_value", "payer_identity", "result_code", "result_message", "timestamp", "total_amount", "transaction_date", "transaction_hash", "transaction_id", "transaction_status", "transaction_type", "updated_at", "user_account", "user_id"]
  end


  scope :current_conference_payments, -> { where('conf_year = ? ', ApplicationSetting.get_current_app_year) }

  def manual_payment_decimal
    if self.transaction_type == "ManuallyEntered"
      if self.total_amount !~ /^\s*[+-]?(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?\s*$/
        errors.add(:total_amount, "must be decimal")
      elsif self.total_amount.to_f < 0
        errors.add(:total_amount, "must be positive")
      end
    end
  end

  def check_manual_amount
    if self.transaction_type == "ManuallyEntered"
      self.total_amount = (self.total_amount.to_f * 100).to_s
    end
  end

end
