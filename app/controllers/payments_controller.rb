require 'digest'
require 'time'

class PaymentsController < ApplicationController
  MAX_PAYMENT_AMOUNT = 2000

  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, only: [:payment_receipt]
  before_action :verify_payment_callback, only: [:payment_receipt]

  before_action :authenticate_user!, except: %i[delete_manual_payment payment_receipt]
  before_action :current_user, only: %i[make_payment payment_show]
  before_action :current_application, only: %i[payment_show]

  before_action :authenticate_admin_user!, only: [:delete_manual_payment]
  prepend_before_action :verify_authenticity_token, only: [:delete_manual_payment]

  def index
    redirect_to root_url
  end

  def payment_receipt
    result = Payments::GatewayReceiptRecorder.new(callback_params: url_params).call

    case result.status
    when :duplicate
      redirect_to all_payments_path
    when :recorded
      redirect_to all_payments_path, notice: 'Your Payment Was Successfully Recorded'
    when :forbidden
      head :forbidden
    else
      head :unprocessable_entity
    end
  end

  def make_payment
    amount = validated_payment_amount(params['amount'])
    if amount.nil?
      redirect_to all_payments_path, alert: 'Please enter a valid payment amount.'
      return
    end

    processed_url = generate_hash(current_user, amount)
    redirect_to processed_url, allow_other_host: true
  end

  def payment_show
    redirect_to root_url unless user_has_payments?(current_user)
    @users_current_payments = Payment.current_conference_payments.where(user_id: current_user.id)
    @ttl_paid = Payment.current_conference_payments.where(user_id: current_user.id, transaction_status: '1').pluck(:total_amount).map(&:to_f).sum / 100
    @has_subscription = @current_application.subscription
    @cost_subscription = @current_application.subscription_cost
    @total_cost = @current_application.total_cost
    @balance_due = @total_cost - @ttl_paid
    @max_payment_amount = max_payment_amount_for(@balance_due)
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

  def verify_payment_callback
    unless params['hash'].present? && params['timestamp'].present? && params['transactionId'].present? && params['orderNumber'].present?
      head :forbidden
      return
    end
  end

  def generate_hash(current_user, amount = 100)
    user_account = current_user.email.partition('@').first + '-' + current_user.id.to_s
    amount_to_be_payed = amount.to_i
    if Rails.env.development? || Rails.env.staging? || Rails.application.credentials.NELNET_SERVICE[:SERVICE_SELECTOR] == 'QA'
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
    current_epoch_time = DateTime.now.strftime('%Q').to_i
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
    hash_to_be_encoded = initial_hash.values.map { |v| "#{v}" }.join('')
    encoded_hash = Digest::SHA256.hexdigest hash_to_be_encoded

    # Final URL
    url_for_payment = initial_hash.map { |k, v| "#{k}=#{v}&" unless k == 'key' }.join('')
    connection_hash[url_to_use] + '?' + url_for_payment + 'hash=' + encoded_hash
  end

  def validated_payment_amount(raw_amount)
    return nil if raw_amount.respond_to?(:blank?) ? raw_amount.blank? : raw_amount.nil?

    amount = Integer(raw_amount, exception: false)
    if amount.nil?
      begin
        amount = BigDecimal(raw_amount.to_s).to_i
      rescue ArgumentError
        return nil
      end
    end
    return nil if amount <= 0

    balance_due = current_balance_due
    return nil if balance_due <= 0

    max_amount = max_payment_amount_for(balance_due)
    return nil if amount > max_amount

    amount
  end

  def max_payment_amount_for(balance_due)
    [balance_due.floor, MAX_PAYMENT_AMOUNT].min
  end

  def current_balance_due
    current_application
    return 0.0 if @current_application.nil?

    total_cost = begin
      @current_application.total_cost
    rescue StandardError => e
      Rails.logger.error("Error computing total_cost for application #{@current_application.id}: #{e.class}: #{e.message}") if defined?(Rails) && Rails.respond_to?(:logger)
      0.0
    end
    total_cost = total_cost.to_f
    total_paid = Payment.current_conference_payments.where(user_id: current_user.id, transaction_status: '1').pluck(:total_amount).map(&:to_f).sum / 100
    total_cost - total_paid
  end

  def url_params
    params.permit(:amount, :transactionType, :transactionStatus, :transactionId, :transactionTotalAmount, :transactionDate, :transactionAcountType, :transactionResultCode, :transactionResultMessage, :orderNumber, :timestamp, :hash, :conf_year)
  end

  def current_application
    @current_application = Application.active_conference_applications.find_by(user_id: current_user.id)
  end
end
