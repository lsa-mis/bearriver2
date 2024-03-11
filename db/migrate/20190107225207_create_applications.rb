class CreateApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :applications do |t|
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.integer :birth_year
      t.string :street
      t.string :street2
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :phone
      t.string :email
      t.string :email_confirmation
      t.string :workshop_selection1
      t.string :workshop_selection2
      t.string :workshop_selection3
      t.string :lodging_selection
      t.string :partner_registration_selection
      t.string :partner_first_name
      t.string :partner_last_name
      t.string :how_did_you_hear
      t.text :accessibility_requirements
      t.text :special_lodging_request
      t.text :food_restrictions
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
