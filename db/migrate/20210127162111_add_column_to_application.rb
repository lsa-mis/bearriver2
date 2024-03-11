class AddColumnToApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :applications, :subscription, :boolean, default: false
  end
end
