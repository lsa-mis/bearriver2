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
  validates :transaction_date, presence: true
  validates :account_type, presence: true, if: :manual_entry?
  belongs_to :user
  has_many :payment_gateway_callbacks, dependent: :nullify, inverse_of: :payment
  validate :manual_payment_decimal
  validate :valid_transaction_date
  before_save :check_manual_amount

  scope :current_conference_payments, -> { where(arel_table[:conf_year].eq(ApplicationSetting.get_current_app_year)) }

  def manual_entry?
    transaction_type == "ManuallyEntered"
  end

  def manual_payment_decimal
    if manual_entry?
      if self.total_amount !~ /^\s*[+-]?(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?\s*$/
        errors.add(:total_amount, "must be decimal")
      elsif self.total_amount.to_f < 0
        errors.add(:total_amount, "must be positive")
      end
    end
  end

  def valid_transaction_date
    return if transaction_date.blank?

    return if valid_transaction_date_format?(transaction_date)

    errors.add(:transaction_date, "must be a valid date")
  end

  def valid_transaction_date_format?(value)
    date_string = value.to_s.strip
    return false if date_string.blank?

    Date.strptime(date_string, '%m/%d/%Y')
    true
  rescue ArgumentError
    begin
      Date.parse(date_string)
      true
    rescue ArgumentError
      false
    end
  end

  def check_manual_amount
    if manual_entry?
      self.total_amount = (self.total_amount.to_f * 100).to_s
    end
  end

end
