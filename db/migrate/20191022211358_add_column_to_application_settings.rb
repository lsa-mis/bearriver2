class AddColumnToApplicationSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :application_settings, :active_application, :boolean, default: false, null: false
  end
end
