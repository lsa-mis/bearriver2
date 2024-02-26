class AddSpecialScholarshipToApplicationSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :application_settings, :special_scholarship_acceptance_directions, :text
  end
end
