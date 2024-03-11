class AddColumnsToApplicationSetting < ActiveRecord::Migration[6.0]
  def change
    add_column :application_settings, :allow_lottery_winner_emails, :boolean, default: false, null: false
    add_column :application_settings, :allow_lottery_loser_emails, :boolean, default: false, null: false
    add_column :application_settings, :registration_fee, :decimal, default: 50.0, null: false
    add_column :application_settings, :lottery_buffer, :integer, default: 50, null: false
    add_column :application_settings, :application_open_directions, :text
    add_column :application_settings, :application_closed_directions, :text
    add_column :application_settings, :application_open_period, :integer, default: 48, null: false
  end
end
