ActiveAdmin.register Lodging do
  menu parent: "Application Configuration", priority: 3
  config.filters = false

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :plan, :description, :cost
  #
  # or
  #
  # permit_params do
  #   permitted = [:plan, :description, :cost]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  config.sort_order = 'id_asc'

  index do
    selectable_column
    actions
    column :id do |id|
      link_to id.id, admin_lodging_path(id)
    end
    column :plan
    column :description
    column "cost" do |fee|
      number_to_currency(fee.cost)
    end
  end

  show do
    attributes_table do
      row :plan
      row :description
      row "cost" do |fee|
        number_to_currency(fee.cost)
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end
