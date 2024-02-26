class CreateApplicationSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :application_settings do |t|
      t.datetime :opendate
      t.integer :application_buffer
      t.integer :contest_year
      t.string :time_zone

      t.timestamps
    end
  end
end
