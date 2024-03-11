class AddAllowPaymentsToApplicationSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :application_settings, :allow_payments, :boolean, default: false
  end
end
