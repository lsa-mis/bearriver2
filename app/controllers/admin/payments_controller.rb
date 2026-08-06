module Admin
  class PaymentsController < BaseController
    before_action :set_payment, only: %i[show destroy]

    def index
      @payments = filtered_payments.includes(:user)

      respond_to do |format|
        format.html
        format.csv do
          send_csv(
            filename: "payments-#{Date.current}.csv",
            headers: payment_csv_headers,
            rows: @payments.map { |payment| payment_csv_row(payment) }
          )
        end
      end
    end

    def show
      @callbacks = @payment.payment_gateway_callbacks.order(created_at: :desc)
      @current_application = @payment.user&.applications&.find_by(conf_year: ApplicationSetting.get_current_app_year)
    end

    def new
      @payment = Payment.new(
        conf_year: ApplicationSetting.get_current_app_year,
        user_id: params[:user_id],
        transaction_type: 'ManuallyEntered',
        transaction_status: '1',
        result_code: 'Manually Entered'
      )
    end

    def create
      @payment = Payment.new(payment_params)
      @payment.transaction_type = 'ManuallyEntered'
      @payment.transaction_status = '1'
      @payment.result_code = 'Manually Entered'
      @payment.result_message = "This was manually entered by #{current_admin_user.email}"
      @payment.transaction_id = "#{DateTime.now.iso8601}_#{current_admin_user.email}"
      @payment.timestamp = DateTime.now.strftime('%Q').to_i
      @payment.conf_year ||= ApplicationSetting.get_current_app_year
      # total_amount is entered in dollars; Payment#check_manual_amount converts to cents

      if @payment.save
        redirect_to admin_payment_path(@payment), notice: 'Payment was successfully created.'
      else
        render :new, status: :unprocessable_content
      end
    end

    def destroy
      unless @payment.transaction_type == 'ManuallyEntered'
        redirect_to admin_payment_path(@payment), alert: 'Only manually entered payments can be deleted.'
        return
      end

      @payment.destroy
      redirect_to admin_payments_path, notice: 'Payment was successfully deleted.'
    end

    private

    def set_payment
      @payment = Payment.find(params[:id])
    end

    def filtered_payments
      scope = case params[:scope]
              when 'all' then Payment.all
              else Payment.current_conference_payments
              end

      scope = scope.where(payer_identity: params[:payer_identity]) if params[:payer_identity].present?
      scope = scope.where(conf_year: params[:conf_year]) if params[:conf_year].present?
      scope = scope.where(account_type: params[:account_type]) if params[:account_type].present?

      if params[:last_name].present? || params[:first_name].present?
        scope = scope.joins(user: :applications)
        scope = scope.where(applications: { last_name: params[:last_name] }) if params[:last_name].present?
        scope = scope.where(applications: { first_name: params[:first_name] }) if params[:first_name].present?
        scope = scope.distinct
      end

      scope.order(created_at: :desc)
    end

    def payment_params
      params.require(:payment).permit(
        :user_id, :conf_year, :total_amount, :transaction_date, :account_type
      )
    end

    def payment_csv_headers
      [
        'User', 'Conf Year', 'Transaction Type', 'Total Amount', 'Transaction Status',
        'Transaction Date', 'Account Type', 'Result Code', 'Result Message', 'Created At', 'Updated At'
      ]
    end

    def payment_csv_row(payment)
      [
        payment.user&.email, payment.conf_year, payment.transaction_type,
        helpers.number_to_currency(payment.total_amount.to_f / 100), payment.transaction_status,
        payment.transaction_date, payment.account_type, payment.result_code, payment.result_message,
        payment.created_at, payment.updated_at
      ]
    end
  end
end
