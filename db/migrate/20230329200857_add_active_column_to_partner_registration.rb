class AddActiveColumnToPartnerRegistration < ActiveRecord::Migration[6.0]
  def change
    add_column :partner_registrations, :active, :boolean
  end
end
