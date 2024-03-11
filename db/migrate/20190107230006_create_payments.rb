class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.string :transaction_type
      t.string :transaction_status
      t.string :transaction_id
      t.string :total_amount
      t.string :transaction_date
      t.string :account_type
      t.string :result_code
      t.string :result_message
      t.string :user_account
      t.string :payer_identity
      t.string :timestamp
      t.string :transaction_hash
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
