class AddPaymentInstColumnToApplicationSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :application_settings, :payments_directions, :text
  end
end
