class CreatePaymentGatewayCallbacks < ActiveRecord::Migration[7.2]
  def change
    create_table :payment_gateway_callbacks do |t|
      t.references :payment, foreign_key: true
      t.references :user, foreign_key: true
      t.string :transaction_id
      t.string :processing_status, null: false
      t.string :event_type, null: false, default: 'receipt'
      t.text :failure_reason
      t.jsonb :payload, null: false, default: {}

      t.timestamps
    end

    add_index :payment_gateway_callbacks, :transaction_id
    add_index :payment_gateway_callbacks, :processing_status
  end
end
