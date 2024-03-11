ActiveAdmin.register AdminUser do
  menu parent: "Admin", priority: 1
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    actions
    id_column
    column :email
    column :created_at
  end

  filter :email
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
