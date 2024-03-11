class AddFieldToApplicationsettings < ActiveRecord::Migration[6.0]
  def change
    add_column :application_settings, :lottery_result, :integer, array: true
    add_column :application_settings, :lottery_run_date, :datetime
  end
end
