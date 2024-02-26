class UpdatePartnerRegistrationIdColumnInApplications < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:applications, :partner_registration_id, false)
  end
end
