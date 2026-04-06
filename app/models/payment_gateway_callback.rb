# == Schema Information
#
# Table name: payment_gateway_callbacks
#
#  id                :bigint           not null, primary key
#  event_type        :string           default("receipt"), not null
#  failure_reason    :text
#  payload           :jsonb            not null
#  processing_status :string           not null
#  transaction_id    :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  payment_id        :bigint
#  user_id           :bigint
#
class PaymentGatewayCallback < ApplicationRecord
  PROCESSING_STATUSES = %w[recorded duplicate rejected error].freeze

  belongs_to :payment, optional: true
  belongs_to :user, optional: true

  validates :processing_status, presence: true, inclusion: { in: PROCESSING_STATUSES }
  validates :event_type, presence: true
  validates :payload, presence: true
end
