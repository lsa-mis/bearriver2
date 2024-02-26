class AddColumnToPayment < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :conf_year, :integer
  end
end
