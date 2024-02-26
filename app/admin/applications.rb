ActiveAdmin.register Application do
  menu parent: "User Mangement", priority: 1
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :first_name, :last_name, :gender, :birth_year, :street, :street2, :city, :state, :zip, :country, :phone, :email, :email_confirmation, :workshop_selection1, :workshop_selection2, :workshop_selection3, :lodging_selection, :partner_registration_selection, :partner_registration_id, :partner_first_name, :partner_last_name, :how_did_you_hear, :accessibility_requirements, :special_lodging_request, :food_restrictions, :user_id, :lottery_position, :offer_status, :result_email_sent, :offer_status_date, :conf_year, :subscription


  scope :active_conference_applications, :default => true, label: "Current years Applications"
  scope :all

  scope :subscription_selected, group: :subscription

  action_item :send_offer, only: :show do
    button_to "Send Offer", send_offer_path(application) if application.offer_status == "not_offered"
  end

  filter :user_id, label: "User", as: :select, collection: -> { Application.all.map { |app| [app.display_name, app.user_id]}.uniq.sort}
  filter :offer_status, as: :select
  filter :result_email_sent, as: :select
  filter :workshop_selection1, label: "workshop_selection1", as: :select, collection: -> { Workshop.all.map { |mapp| [mapp.instructor, mapp.instructor]}.sort }
  filter :workshop_selection2, label: "workshop_selection2", as: :select, collection: -> { Workshop.all.map { |mapp| [mapp.instructor, mapp.instructor]}.sort }
  filter :workshop_selection3, label: "workshop_selection3", as: :select, collection: -> { Workshop.all.map { |mapp| [mapp.instructor, mapp.instructor]}.sort }
  filter :lodging_selection, as: :select, collection: -> { Lodging.all.map { |lapp| [lapp.description, lapp.description]}.sort }
  filter :partner_registration_id, as: :select, collection: -> { PartnerRegistration.all.map { |papp| [papp.description, papp.id]}.sort }
  filter :conf_year, as: :select

  index do
    selectable_column
    actions
    column :offer_status
    column "Balance Due" do |application|
      users_current_payments = Payment.where(user_id: application.user_id, conf_year: application.conf_year)
      ttl_paid = Payment.where(user_id: application.user_id, conf_year: application.conf_year, transaction_status: '1').pluck(:total_amount).map(&:to_f).sum / 100
      cost_lodging = Lodging.find_by(description: application.lodging_selection).cost.to_f
      cost_partner = application.partner_registration.cost.to_f
      total_cost = cost_lodging + cost_partner
      balance_due = total_cost - ttl_paid
      number_to_currency(balance_due)
    end
    column :first_name
    column :last_name
    column :workshop_selection1
    column :workshop_selection2
    column :workshop_selection3
    column :lodging_selection
    column "partner_registration_id" do |application|
      application.partner_registration.display_name
    end
    column :birth_year
  end

  show do

    users_current_payments = Payment.where(user_id: application.user_id, conf_year: application.conf_year) # Payment.current_conference_payments.where(user_id: application.user_id)
    ttl_paid = Payment.where(user_id: application.user_id, conf_year: application.conf_year, transaction_status: '1').pluck(:total_amount).map(&:to_f).sum / 100
    cost_lodging = Lodging.find_by(description: application.lodging_selection).cost.to_f
    cost_partner = application.partner_registration.cost.to_f
    total_cost = cost_lodging + cost_partner
    balance_due = total_cost - ttl_paid
    panel "Payment Activity -- [Balance Due: #{number_to_currency(balance_due)} Total Cost: #{number_to_currency(total_cost)}]" do
      table_for application.user.payments.where(conf_year: application.conf_year) do #application.user.payments.current_conference_payments
        column(:id) { |aid| link_to(aid.id, admin_payment_path(aid.id)) }
        column(:account_type) { |atype| atype.account_type.titleize }
        column(:transaction_type) 
        column(:transaction_date) {|td| Date.parse(td.transaction_date) }
        column(:total_amount) { |ta|  number_to_currency(ta.total_amount.to_f / 100) }
      end
      text_node link_to("[Add Manual Payment]", new_admin_payment_path(:user_id => application))
    end

    
    attributes_table do
      row :user
      row :conf_year
      row :lottery_position
      row :offer_status
      row :offer_status_date
      row :result_email_sent
      row :subscription
      row :first_name
      row :last_name
      row :gender
      row :birth_year
      row :street
      row :street2
      row :city
      row :state
      row :zip
      row :country
      row :phone
      row :email
      row :email_confirmation
      row :workshop_selection1
      row :workshop_selection2
      row :workshop_selection3
      row :lodging_selection
      row "partner_registration_id" do |app|
        app.partner_registration.display_name
      end
      row :partner_first_name
      row :partner_last_name
      row :how_did_you_hear
      row :accessibility_requirements
      row :special_lodging_request
      row :food_restrictions
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :user
      li "Conf Year #{f.object.conf_year}" unless f.object.new_record?
      f.input :conf_year, input_html: {value: ApplicationSetting.get_current_app_year} unless f.object.persisted?
      f.input :lottery_position, input_html: { disabled: true }
      f.input :offer_status, :label => "Offer status", :as => :select, :collection => offer_status
      f.input :offer_status_date
      f.input :subscription
      f.input :first_name
      f.input :last_name
      f.input :gender, :label => "Gender", :as => :select, :collection => Gender.all.map { |g| ["#{g.name}", g.name] }
      f.input :birth_year
      f.input :street
      f.input :street2
      f.input :city
      f.input :state, :label => "State", :as => :select, :collection => us_states
      f.input :zip
      f.input :country, include_blank: true
      f.input :phone
      f.input :email
      f.input :workshop_selection1, :label => "Workshop First Choice", :as => :select, :collection => Workshop.all.map { |w| ["#{w.instructor}", w.instructor] }
      f.input :workshop_selection2, :label => "Workshop Second Choice", :as => :select, :collection => Workshop.all.map { |w| ["#{w.instructor}", w.instructor] }
      f.input :workshop_selection3, :label => "Workshop Third Choice", :as => :select, :collection => Workshop.all.map { |w| ["#{w.instructor}", w.instructor] }
      f.input :lodging_selection, :label => "Lodging selection", :as => :select, :collection => Lodging.all.map { |l| ["Plan:#{l.plan} #{l.description} #{number_to_currency(l.cost.to_f)}", l.description] }
      f.input :partner_registration_id, :label => "Partner Registration Selection", :as => :select, :collection => PartnerRegistration.all.map { |p| ["#{p.display_name}", p.id] }
      f.input :partner_first_name
      f.input :partner_last_name
      f.input :how_did_you_hear
      f.input :accessibility_requirements
      f.input :special_lodging_request
      f.input :food_restrictions
    end
    f.actions
  end

  csv do
    column :user do |application|
      application.name
    end
    column :email
    column :conf_year
    column :lottery_position
    column :offer_status
    column "Balance Due" do |application|
      users_current_payments = Payment.current_conference_payments.where(user_id: application.user_id)
      ttl_paid = Payment.current_conference_payments.where(user_id: application.user_id, transaction_status: '1').pluck(:total_amount).map(&:to_f).sum / 100
      cost_lodging = Lodging.find_by(description: application.lodging_selection).cost.to_f
      cost_partner = application.partner_registration.cost.to_f
      total_cost = cost_lodging + cost_partner
      balance_due = total_cost - ttl_paid
      number_to_currency(balance_due)
    end
    column :subscription
    column :first_name
    column :last_name
    column :gender
    column :workshop_selection1
    column :workshop_selection2
    column :workshop_selection3
    column :lodging_selection
    column "partner_registration_id" do |app|
      app.partner_registration.display_name
    end
    column :birth_year
    column :street
    column :street2
    column :city
    column :state
    column :zip
    column :country
    column :phone
    column :email
    column :email_confirmation
    column :partner_first_name
    column :partner_last_name
    column :how_did_you_hear
    column :accessibility_requirements
    column :special_lodging_request
    column :food_restrictions
    column :result_email_sent
    column :offer_status_date
  end


end
