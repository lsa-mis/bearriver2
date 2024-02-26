class AddColumnsToApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :applications, :conf_year, :integer
    add_column :applications, :lottery_position, :integer
    add_column :applications, :offer_status, :string
    add_column :applications, :result_email_sent, :boolean, default: false, null: false 
  end
end
