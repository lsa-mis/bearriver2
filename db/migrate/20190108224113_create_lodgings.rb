class CreateLodgings < ActiveRecord::Migration[5.2]
  def change
    create_table :lodgings do |t|
      t.string :plan
      t.string :description
      t.decimal :cost

      t.timestamps
    end
  end
end
