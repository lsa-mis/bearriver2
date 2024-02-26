class AddPartnerRegistrationReferenceToApplication < ActiveRecord::Migration[6.0]
  def change
    add_reference :applications, :partner_registration, foreign_key: true
  end
end
