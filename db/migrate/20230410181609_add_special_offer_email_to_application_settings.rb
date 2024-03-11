class AddSpecialOfferEmailToApplicationSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :application_settings, :special_offer_invite_email, :text
  end
end
