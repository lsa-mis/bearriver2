  require 'digest'
  require 'time'

  class PaymentsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:payment_receipt, :delete_manual_payment]
    before_action :authenticate_user!, except: [:delete_manual_payment]
    before_action :current_user, only: %i[payment_receipt make_payment payment_show]
    before_action :current_application, only: %i[payment_receipt payment_show]
    before_action :authenticate_admin_user!, only: [:delete_manual_payment]

    def index
      redirect_to root_url
    end

    def payment_receipt
      if Payment.pluck(:transaction_id).include?(params['transactionId'])
        redirect_to all_payments_path
      else
        Payment.create(
          transaction_type: params['transactionType'],
          transaction_status: params['transactionStatus'],
          transaction_id: params['transactionId'],
          total_amount: params['transactionTotalAmount'],
          transaction_date: params['transactionDate'],
          account_type: params['transactionAcountType'],
          result_code: params['transactionResultCode'],
          result_message: params['transactionResultMessage'],
          user_account: params['orderNumber'],
          payer_identity: @current_user.email,
          timestamp: params['timestamp'],
          transaction_hash: params['hash'],
          user_id: current_user.id,
          conf_year: ApplicationSetting.get_current_app_year
        )
        @current_application.update(offer_status: "registration_accepted")
        redirect_to all_payments_path, notice: "Your Payment Was Successfully Recorded"
      end
    end

    def make_payment
      processed_url = generate_hash(@current_user, params['amount'])
      redirect_to processed_url
    end

    def payment_show
      redirect_to root_url unless user_has_payments?(current_user)
      @users_current_payments = Payment.current_conference_payments.where(user_id: current_user )
      @ttl_paid = Payment.current_conference_payments.where(user_id: current_user, transaction_status: '1').pluck(:total_amount).map(&:to_f).sum / 100
      cost_lodging = Lodging.find_by(description: @current_application.lodging_selection).cost.to_f
      cost_partner = @current_application.partner_registration.cost.to_f
      @total_cost = cost_lodging + cost_partner
      @balance_due = @total_cost - @ttl_paid
    end

    def delete_manual_payment
      @payment = Payment.find(params[:id])
      @payment.destroy
      respond_to do |format|
        format.html { redirect_to admin_payments_url, notice: 'Payment was successfully deleted.' }
        format.json { head :no_content }
      end
    end

    private
      def generate_hash(current_user, amount=100)
        user_account = current_user.email.partition('@').first + '-' + current_user.id.to_s
        amount_to_be_payed = amount.to_i
        if Rails.env.development? || Rails.application.credentials.NELNET_SERVICE[:SERVICE_SELECTOR] == "QA"
           key_to_use = 'test_key'
           url_to_use = 'test_URL'
         else
           key_to_use = 'prod_key'
           url_to_use = 'prod_URL'
         end

        connection_hash = {
         'test_key' => Rails.application.credentials.NELNET_SERVICE[:DEVELOPMENT_KEY],
         'test_URL' => Rails.application.credentials.NELNET_SERVICE[:DEVELOPMENT_URL],
         'prod_key' => Rails.application.credentials.NELNET_SERVICE[:PRODUCTION_KEY],
         'prod_URL' => Rails.application.credentials.NELNET_SERVICE[:PRODUCTION_URL]
        }

        redirect_url = connection_hash[url_to_use]
        current_epoch_time = DateTime.now.strftime("%Q").to_i
        initial_hash = {
          'orderNumber' => user_account,
          'orderType' => 'English Department Online',
          'orderDescription' => 'Bearriver Conference Fees',
          'amountDue' => amount_to_be_payed * 100,
          'redirectUrl' => redirect_url,
          'redirectUrlParameters' => 'transactionType,transactionStatus,transactionId,transactionTotalAmount,transactionDate,transactionAcountType,transactionResultCode,transactionResultMessage,orderNumber',
          'retriesAllowed' => 1,
          'timestamp' => current_epoch_time,
          'key' => connection_hash[key_to_use]
        }

        # Sample Hash Creation
        hash_to_be_encoded = initial_hash.values.map{|v| "#{v}"}.join('')
        encoded_hash =  Digest::SHA256.hexdigest hash_to_be_encoded

        # Final URL
        url_for_payment = initial_hash.map{|k,v| "#{k}=#{v}&" unless k == 'key'}.join('')
        final_url = connection_hash[url_to_use] + '?' + url_for_payment + 'hash=' + encoded_hash
      end

      def url_params
        params.permit(:amount, :transactionType, :transactionStatus, :transactionId, :transactionTotalAmount, :transactionDate, :transactionAcountType, :transactionResultCode, :transactionResultMessage, :orderNumber, :timestamp, :hash, :conf_year)
      end

      def current_application
        @current_application = Application.active_conference_applications.find_by(user_id: current_user)
      end
  end
