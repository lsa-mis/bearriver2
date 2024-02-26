ActiveAdmin.register PartnerRegistration do
  menu parent: "Application Configuration", priority: 3
  config.filters = false

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :description, :cost, :active
  #
  # or
  #
  # permit_params do
  #   permitted = [:description, :cost]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  index do
    selectable_column
    actions
    column :id do |id|
      link_to id.id, admin_partner_registration_path(id)
    end
    column :description
    column "cost" do |fee|
      number_to_currency(fee.cost)
    end
    column :active
  end

  show do
    attributes_table do
      row :description
      row "cost" do |fee|
        number_to_currency(fee.cost)
      end
      row :active
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end
