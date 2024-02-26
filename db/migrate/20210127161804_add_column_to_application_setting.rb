class AddColumnToApplicationSetting < ActiveRecord::Migration[6.0]
  def change
    add_column :application_settings, :subscription_cost, :integer, default: 0, null: false
  end
end
