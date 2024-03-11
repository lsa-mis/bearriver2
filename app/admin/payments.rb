ActiveAdmin.register Payment do
  actions :index, :show, :create, :new
  action_item :delete_manual_payment, only: :show do
    link_to('Delete Manual Payment', delete_manual_payment_path(payment), method: :post, data: { confirm: 'Are you sure?' }) if payment.transaction_type == "ManuallyEntered"
  end
  menu parent: "User Mangement", priority: 2

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :transaction_type, :transaction_status, :transaction_id, :total_amount, :transaction_date, :account_type, :result_code, :result_message, :user_account, :payer_identity, :timestamp, :transaction_hash, :user_id, :conf_year
  #
  # or
  #
  # permit_params do
  #   permitted = [:transaction_type, :transaction_status, :transaction_id, :total_amount, :transaction_date, :account_type, :result_code, :result_message, :user_account, :payer_identity, :timestamp, :transaction_hash, :user_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
  # filter :user, as: :select, collection: -> { User.all.order(:email) }
  # filter user.current_application, label: "Last Name (Starts with)"
  # filter :application_first_name_start, label: "First Name (Starts with)"

  scope :current_conference_payments
  scope :all

  filter :user_id, as: :select,
    # collection: -> { User.all.order(:email) },
    collection: -> { Application.all.order(:last_name).map { |app| [app.display_name, app.user_id] } },
    label: "Name"
  filter :conf_year, as: :select


  index do
    selectable_column
    actions
    column :id do |id|
      link_to id.id, admin_payment_path(id)
    end
    column :user
    column :conf_year
    column :transaction_type
    column "total_amount" do |amount|
      number_to_currency(amount.total_amount.to_f / 100)
    end
    column :transaction_status
    # column :transaction_id

    column :transaction_date
    column :account_type
    column :result_code
    column :result_message
    # column :user_account
    # column :payer_identity
    # column :timestamp
    # column :transaction_hash
    column :created_at
    column :updated_at
  end

  show do
    attributes_table do
      row :user do |user| 
        if (app = payment.user.applications.find_by(conf_year: ApplicationSetting.get_current_app_year))
          link_to(app.display_name, admin_application_path(app))
        else
          payment.user
        end
      end
      # row :user
      row :conf_year
      row :transaction_type
      row :transaction_status
      row :transaction_id
      row "total_amount" do |amount|
        number_to_currency(amount.total_amount.to_f / 100)
      end
      row :transaction_date
      row :account_type
      row :result_code
      row :result_message
      row :user_account
      row :payer_identity
      row :timestamp
      row :transaction_hash
      row :user_id
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.inputs "Payment" do
      if params[:user_id]
        li "<strong>User: #{User.find(params[:user_id]).display_name}</strong>".html_safe
        f.input :user_id, input_html: {value: params[:user_id]}, as: :hidden
      else
        f.input :user, as: :select, :collection => User.all.map { |u| ["#{u.email}", u.id] }.sort  # Application.active_conference_applications.map { |a| ["#{a.display_name}", a.user_id] }.sort
      end
      li "Conf Year #{f.object.conf_year}" unless f.object.new_record?
      f.input :conf_year, input_html: {value: ApplicationSetting.get_current_app_year} unless f.object.persisted?
      f.input :transaction_type, as: :hidden, :input_html => { value: "ManuallyEntered" } # ManualEntry
      f.input :transaction_status, as: :hidden, :input_html => { value: "1" } # 1
      f.input :transaction_id, as: :hidden, :input_html => { value: DateTime.now.iso8601 + "_" + current_admin_user.email } # DateTime.now.iso8601 + current_admin_user.email
      f.input :total_amount, label: "Total amount in $" # 10000 => 100.00
      f.input :transaction_date, as: :datepicker # DateTime.now.iso8601
      f.input :account_type, collection: ['scholarship', 'special', 'other']
      f.input :result_code, as: :hidden, :input_html => { value: "Manually Entered" } # 'Manually Entered'
      f.input :result_message, as: :hidden, :input_html => { value: "This was manually entered by #{current_admin_user.email}" }
      f.input :timestamp, as: :hidden, :input_html => { value: DateTime.now.strftime("%Q").to_i } # DateTime.now.strftime("%Q").to_i
    end
    f.actions
  end

  csv do
    column :user
    column :conf_year
    column :transaction_type
    column "total_amount" do |amount|
      number_to_currency(amount.total_amount.to_f / 100)
    end
    column :transaction_status
    column :transaction_date
    column :account_type
    column :result_code
    column :result_message
    column :created_at
    column :updated_at
    column "Comments" do |payment|
      ActiveAdmin::Comment.where(resource_type: 'Payment', resource_id: payment).pluck(:body)
    end
  end
end
