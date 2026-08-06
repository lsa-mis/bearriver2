module Admin
  class ApplicationsController < BaseController
    before_action :set_application, only: %i[show edit update destroy send_offer]
    before_action :load_index_batch_data, only: :index

    def index
      @applications = filtered_applications.includes(:partner_registration, :user)

      respond_to do |format|
        format.html
        format.csv do
          send_csv(
            filename: "applications-#{Date.current}.csv",
            headers: application_csv_headers,
            rows: @applications.map { |app| application_csv_row(app) }
          )
        end
      end
    end

    def show
      if @application.partner_registration.nil?
        redirect_to edit_admin_application_path(@application),
                    alert: 'Partner registration is missing; set it before viewing balance details.'
        return
      end

      @ttl_paid = Payment.where(user_id: @application.user_id, conf_year: @application.conf_year, transaction_status: '1')
                         .pluck(:total_amount).map(&:to_f).sum / 100
      @total_cost = @application.total_cost
      @balance_due = @total_cost - @ttl_paid
      @payments = @application.user.payments.where(conf_year: @application.conf_year).order(created_at: :desc)
    end

    def new
      @application = Application.new(conf_year: ApplicationSetting.get_current_app_year)
    end

    def edit
    end

    def create
      @application = Application.new(application_params)
      if @application.save
        redirect_to admin_application_path(@application), notice: 'Application was successfully created.'
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @application.update(application_params)
        redirect_to admin_application_path(@application), notice: 'Application was successfully updated.'
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @application.destroy
      redirect_to admin_applications_path, notice: 'Application was successfully deleted.'
    end

    def send_offer
      if @application.update(offer_status: 'registration_offered', offer_status_date: Time.current, result_email_sent: true)
        LotteryMailer.with(application: @application).waitlisted_offer_email.deliver_now
        redirect_to admin_application_path(@application), notice: 'Offer sent.'
      else
        redirect_to admin_application_path(@application),
                    alert: "Could not send offer: #{@application.errors.full_messages.to_sentence}"
      end
    end

    def send_balance_due
      message_count = 0
      Application.application_accepted.each do |application|
        if application.balance_due > 0
          BalanceDueMailer.with(app: application).outstanding_balance.deliver_now
          message_count += 1
        end
      end
      current_application_settings&.update(balance_due_emails_last_sent_at: Time.current)
      flash[:alert] = "#{message_count} balance due messages sent."
      redirect_to admin_root_path
    end

    private

    def set_application
      @application = Application.find(params[:id])
    end

    def load_index_batch_data
      raw = Payment.where(transaction_status: '1').group(:user_id, :conf_year).sum(Arel.sql('total_amount::numeric'))
      @payments_total_by_user_and_year = raw.transform_keys { |k| [k[0].to_i, k[1].to_i] }
      @lodgings_by_description = Lodging.all.index_by(&:description)
    end

    def filtered_applications
      scope = case params[:scope]
              when 'all' then Application.all
              when 'subscription_selected' then Application.subscription_selected
              else Application.active_conference_applications
              end

      scope = scope.joins(:user).where(users: { email: params[:user_email] }) if params[:user_email].present?
      scope = scope.where(last_name: params[:last_name]) if params[:last_name].present?
      scope = scope.where(first_name: params[:first_name]) if params[:first_name].present?
      scope = scope.where(offer_status: params[:offer_status]) if params[:offer_status].present?
      scope = scope.where(result_email_sent: params[:result_email_sent]) if params[:result_email_sent].present?
      scope = scope.where(workshop_selection1: params[:workshop_selection1]) if params[:workshop_selection1].present?
      scope = scope.where(workshop_selection2: params[:workshop_selection2]) if params[:workshop_selection2].present?
      scope = scope.where(workshop_selection3: params[:workshop_selection3]) if params[:workshop_selection3].present?
      scope = scope.where(lodging_selection: params[:lodging_selection]) if params[:lodging_selection].present?
      scope = scope.where(partner_registration_id: params[:partner_registration_id]) if params[:partner_registration_id].present?
      scope = scope.where(subscription: params[:subscription]) if params[:subscription].present?
      scope = scope.where(conf_year: params[:conf_year]) if params[:conf_year].present?
      scope.order(created_at: :desc)
    end

    def application_params
      params.require(:application).permit(
        :first_name, :last_name, :gender, :birth_year, :street, :street2, :city, :state, :zip,
        :country, :phone, :email, :email_confirmation, :workshop_selection1, :workshop_selection2,
        :workshop_selection3, :lodging_selection, :partner_registration_selection, :partner_registration_id,
        :partner_first_name, :partner_last_name, :how_did_you_hear, :accessibility_requirements,
        :special_lodging_request, :food_restrictions, :user_id, :lottery_position, :offer_status,
        :result_email_sent, :offer_status_date, :conf_year, :subscription
      )
    end

    def application_csv_headers
      [
        'User', 'Email', 'Conf Year', 'Lottery Position', 'Offer Status', 'Balance Due', 'Subscription',
        'First Name', 'Last Name', 'Gender', 'Workshop Selection1', 'Workshop Selection2', 'Workshop Selection3',
        'Lodging Selection', 'Partner Registration', 'Birth Year', 'Street', 'Street2', 'City', 'State',
        'Zip', 'Country', 'Phone', 'Email Confirmation', 'Partner First Name', 'Partner Last Name',
        'How Did You Hear', 'Accessibility Requirements', 'Special Lodging Request', 'Food Restrictions',
        'Result Email Sent', 'Offer Status Date'
      ]
    end

    def application_csv_row(application)
      balance = if application.partner_registration.nil?
                  'N/A'
                else
                  helpers.number_to_currency(
                    application.balance_due_with_batch(
                      payments_totals: @payments_total_by_user_and_year,
                      lodgings_by_desc: @lodgings_by_description
                    )
                  )
                end

      [
        application.name, application.email, application.conf_year, application.lottery_position,
        application.offer_status, balance, application.subscription, application.first_name,
        application.last_name, application.gender, application.workshop_selection1,
        application.workshop_selection2, application.workshop_selection3, application.lodging_selection,
        application.partner_registration&.display_name, application.birth_year, application.street,
        application.street2, application.city, application.state, application.zip, application.country,
        application.phone, application.email_confirmation, application.partner_first_name,
        application.partner_last_name, application.how_did_you_hear, application.accessibility_requirements,
        application.special_lodging_request, application.food_restrictions, application.result_email_sent,
        application.offer_status_date
      ]
    end
  end
end
