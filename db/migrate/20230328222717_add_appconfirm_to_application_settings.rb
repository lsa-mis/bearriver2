class AddAppconfirmToApplicationSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :application_settings, :application_confirm_email_message, :text
  end
end
