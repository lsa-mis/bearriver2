class AddActiveColumnDefaultToPartnerRegistration < ActiveRecord::Migration[6.0]
  def change
    change_column_null :partner_registrations, :active, true
    change_column_default :partner_registrations, :active, from: nil, to: true
  end
end
