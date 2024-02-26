class CreateWorkshops < ActiveRecord::Migration[5.2]
  def change
    create_table :workshops do |t|
      t.string :instructor
      t.string :last_name
      t.string :first_name

      t.timestamps
    end
  end
end
