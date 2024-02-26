class CreatePartnerRegistrations < ActiveRecord::Migration[5.2]
  def change
    create_table :partner_registrations do |t|
      t.string :description
      t.decimal :cost

      t.timestamps
    end
  end
end
