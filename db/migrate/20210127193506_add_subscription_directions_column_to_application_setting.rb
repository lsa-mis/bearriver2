class AddSubscriptionDirectionsColumnToApplicationSetting < ActiveRecord::Migration[6.0]
  def change
    add_column :application_settings, :subscription_directions, :text
  end
end
