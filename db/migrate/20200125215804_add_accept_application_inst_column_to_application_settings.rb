class AddAcceptApplicationInstColumnToApplicationSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :application_settings, :registration_acceptance_directions, :text
  end
end
