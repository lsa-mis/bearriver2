# Enforces transaction_id uniqueness at the DB level (concurrent callbacks).
# If this migration fails, resolve duplicate transaction_id values in payments first.
class AddUniqueIndexOnPaymentsTransactionId < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :payments, :transaction_id, unique: true, algorithm: :concurrently
  end
end
