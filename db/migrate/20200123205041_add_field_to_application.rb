class AddFieldToApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :applications, :offer_status_date, :datetime
  end
end
