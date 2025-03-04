ActiveAdmin.register Workshop do
  menu parent: "Application Configuration", priority: 5
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :instructor, :last_name, :first_name, :active
  #
  # or
  #
  # permit_params do
  #   permitted = [:instructor, :last_name, :first_name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  filter :last_name, as: :select
  filter :active
  index do
    selectable_column
    actions
    id_column
    column :active
    column :instructor
    column :last_name
    column :first_name
    column :created_at
    column :updated_at
  end
end
