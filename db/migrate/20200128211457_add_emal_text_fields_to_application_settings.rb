class AddEmalTextFieldsToApplicationSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :application_settings, :lottery_won_email, :text
    add_column :application_settings, :lottery_lost_email, :text
  end
end
