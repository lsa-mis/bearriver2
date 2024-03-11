class AddPaymentreminderToApplicationSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :application_settings, :balance_due_email_message, :text
  end
end
