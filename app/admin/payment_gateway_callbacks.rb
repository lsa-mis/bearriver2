ActiveAdmin.register PaymentGatewayCallback do
  menu parent: 'User Management', priority: 2.5, label: 'Gateway callbacks'

  actions :index, :show

  config.sort_order = 'created_at_desc'

  filter :transaction_id
  filter :processing_status, as: :select, collection: PaymentGatewayCallback::PROCESSING_STATUSES
  filter :event_type
  filter :user
  filter :payment
  filter :created_at

  index do
    actions
    column :id do |callback|
      link_to callback.id, admin_payment_gateway_callback_path(callback)
    end
    column :transaction_id
    column :processing_status
    column :event_type
    column :user
    column :payment
    column :failure_reason do |callback|
      truncate(callback.failure_reason.to_s, length: 80)
    end
    column :created_at
  end

  show do
    attributes_table do
      row :id
      row :transaction_id
      row :processing_status
      row :event_type
      row :user do |callback|
        if callback.user
          link_to(callback.user.email, admin_user_path(callback.user))
        end
      end
      row :payment do |callback|
        if callback.payment
          link_to("Payment ##{callback.payment.id}", admin_payment_path(callback.payment))
        end
      end
      row :failure_reason
      row :created_at
      row :updated_at
      row :payload do |callback|
        pre JSON.pretty_generate(callback.payload.presence || {})
      end
    end
  end
end
