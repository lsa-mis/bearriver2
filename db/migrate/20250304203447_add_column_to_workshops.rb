class AddColumnToWorkshops < ActiveRecord::Migration[7.1]
  def change
    add_column :workshops, :active, :boolean, default: true
  end
end
