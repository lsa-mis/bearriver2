ActiveAdmin.register Payment do
  actions :index, :show, :create, :new
  action_item :delete_manual_payment, only: :show do
    link_to('Delete Manual Payment', delete_manual_payment_path(payment), method: :post, data: { confirm: 'Are you sure?' }) if payment.transaction_type == "ManuallyEntered"
  end
  menu parent: "User Management", priority: 2

  permit_params :transaction_type, :transaction_status, :transaction_id, :total_amount, :transaction_date, :account_type, :result_code, :result_message, :user_account, :payer_identity, :timestamp, :transaction_hash, :user_id, :conf_year

  scope :current_conference_payments
  scope :all

  filter :payer_identity, as: :select,
    collection: -> { Payment.order(:payer_identity).distinct.pluck(:payer_identity) },
    label: "User Email"
  filter :user_applications_last_name, as: :select,
    collection: -> { Application.joins(user: :payments).distinct.order(:last_name).pluck(:last_name) },
    label: "Last Name"
  filter :user_applications_first_name, as: :select,
    collection: -> { Application.joins(user: :payments).distinct.order(:first_name).pluck(:first_name) },
    label: "First Name"
  filter :payments_conf_year, as: :select,
    collection: -> { Payment.order(:conf_year).distinct.pluck(:conf_year) },
    label: "Payment Conf Year"

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
    column :transaction_date
    column :account_type
    column :result_code
    column :result_message
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
        f.input :user, as: :select, :collection => User.all.map { |u| ["#{u.email}", u.id] }.sort
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
      f.input :timestamp, as: :hidden, :input_html => { value: DateTime.now.strftime("%Q").to_i }
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
