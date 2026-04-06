FactoryBot.define do
  factory :payment_gateway_callback do
    processing_status { 'recorded' }
    event_type { 'receipt' }
    transaction_id { "txn_#{SecureRandom.hex(4)}" }
    payload do
      {
        'transactionId' => transaction_id,
        'timestamp' => Time.current.to_i.to_s,
        'hash' => SecureRandom.hex(8),
        'orderNumber' => "user-#{create(:user).id}"
      }
    end
  end
end
