ActiveAdmin.register ApplicationSetting do
  menu parent: "Application Configuration", priority: 1
  config.filters = false

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :opendate, :application_buffer, :contest_year, :time_zone, :allow_payments, :active_application, :allow_lottery_winner_emails, :allow_lottery_loser_emails, :registration_fee, :lottery_buffer, :application_open_directions, :application_closed_directions, :application_open_period, :registration_acceptance_directions, :special_scholarship_acceptance_directions, :payments_directions, :application_confirm_email_message, :balance_due_email_message, :lottery_won_email, :special_offer_invite_email, :lottery_lost_email, :subscription_cost, :subscription_directions

  # remove all existing action items
  actions :all, :except => [:new]

  action_item :duplicate_conference, only: :index do
    text_node link_to("Duplicate Conference Setting", duplicate_conference_path, data: { confirm: 'This will create a new conference and duplicate the most current settings?'}, method: :post )
  end

  index do
    selectable_column
    actions
    column :id do |id|
      link_to id.id, admin_application_setting_path(id)
    end
    column :active_application
    column "Conference Year", :contest_year
    column :opendate
    column "# of hours to keep app open", :application_open_period
    column :application_buffer
    column :time_zone
    column "registration_fee" do |reg_fee|
      number_to_currency(reg_fee.registration_fee)
    end
    column "subscription_cost" do |sub_fee|
      number_to_currency(sub_fee.subscription_cost)
    end
    column :lottery_buffer
    column :lottery_run_date
    column :allow_payments
    column :allow_lottery_winner_emails
    column :allow_lottery_loser_emails
  end

  show do
    attributes_table do
      row :opendate
      row "# of hours to keep app open", &:application_open_period
      row :application_buffer
      row "Conference Year", &:contest_year
      row :time_zone
      row :allow_payments
      row :active_application
      row :allow_lottery_winner_emails
      row :allow_lottery_loser_emails
      row "registration_fee" do |reg_fee|
        number_to_currency(reg_fee.registration_fee)
      end
      row "subscription_cost" do |sub_fee|
        number_to_currency(sub_fee.subscription_cost)
      end
      row :lottery_buffer
      row :lottery_result
      row :lottery_run_date
      row :application_open_directions
      row :application_closed_directions
      row :registration_acceptance_directions
      row :special_scholarship_acceptance_directions
      row :payments_directions
      row :subscription_directions
      row :application_confirm_email_message
      row :lottery_won_email
      row :special_offer_invite_email
      row :lottery_lost_email
      row :balance_due_email_message
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.inputs "ApplicationSetting" do
      f.input :active_application
      f.input :contest_year, label: "Conference Year"
      f.input :opendate
      f.input :time_zone
      f.input :application_open_period, label: "# of Hours App is OPEN"
      f.input :lottery_buffer
      f.input :application_buffer
      f.input :registration_fee
      f.input :subscription_cost
      f.input :application_open_directions
      f.input :application_closed_directions
      f.input :registration_acceptance_directions
      f.input :special_scholarship_acceptance_directions
      f.input :payments_directions
      f.input :subscription_directions

      f.input :application_confirm_email_message
      f.input :lottery_won_email
      f.input :special_offer_invite_email
      f.input :lottery_lost_email
      f.input :balance_due_email_message

      f.input :allow_payments
      f.input :allow_lottery_winner_emails
      f.input :allow_lottery_loser_emails
    end
    f.actions
  end
end
