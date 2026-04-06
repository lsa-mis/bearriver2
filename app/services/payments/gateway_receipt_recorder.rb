module Payments
  class GatewayReceiptRecorder
    # payment is only set for :recorded; other outcomes pass payment: nil explicitly for clarity.
    Result = Struct.new(:status, :payment, keyword_init: true)

    # Matches generate_hash: "<email_local_part>-<user_id>"
    # Greedy .+ anchors the final "-<digits>" segment as user id (supports hyphens in local part).
    ORDER_NUMBER_PATTERN = /\A(.+)-(\d+)\z/

    def initialize(callback_params:)
      @callback_params = callback_params.to_h
    end

    def call
      callback_user = resolve_user_from_order_number
      return callback_user if callback_user.is_a?(Result)

      if Payment.exists?(transaction_id: transaction_id)
        record_callback('duplicate', callback_user)
        return Result.new(status: :duplicate, payment: nil)
      end

      payment = Payment.new(payment_attributes(callback_user))
      if payment.save
        current_application_for(callback_user)&.update(offer_status: 'registration_accepted')
        record_callback('recorded', callback_user, payment)
        Result.new(status: :recorded, payment: payment)
      else
        record_callback('error', callback_user, nil, payment.errors.full_messages.join(', '))
        Result.new(status: :error, payment: nil)
      end
    end

    private

    attr_reader :callback_params

    def transaction_id
      callback_params['transactionId']
    end

    def resolve_user_from_order_number
      parsed = parse_order_number(callback_params['orderNumber'])
      return reject_callback('invalid_order_number') if parsed.is_a?(Symbol)

      prefix, user_id = parsed
      user = User.find_by(id: user_id)
      return reject_callback('user_not_found') if user.nil?

      email_local = user.email.to_s.partition('@').first
      return reject_callback('order_number_mismatch') unless email_local == prefix

      user
    end

    # Returns :invalid_format, :invalid_user_id, or [email_local_prefix, user_id Integer]
    def parse_order_number(raw)
      order_number = raw.to_s.strip
      match = order_number.match(ORDER_NUMBER_PATTERN)
      return :invalid_format unless match

      prefix = match[1]
      return :invalid_format if prefix.blank?

      user_id = Integer(match[2], 10)
      return :invalid_user_id if user_id <= 0

      [prefix, user_id]
    rescue ArgumentError, TypeError
      :invalid_user_id
    end

    def current_application_for(user)
      Application.active_conference_applications.find_by(user_id: user.id)
    end

    def payment_attributes(user)
      {
        transaction_type: callback_params['transactionType'],
        transaction_status: callback_params['transactionStatus'],
        transaction_id: transaction_id,
        total_amount: callback_params['transactionTotalAmount'],
        transaction_date: callback_params['transactionDate'],
        account_type: callback_params['transactionAcountType'],
        result_code: callback_params['transactionResultCode'],
        result_message: callback_params['transactionResultMessage'],
        user_account: callback_params['orderNumber'],
        payer_identity: user.email,
        timestamp: callback_params['timestamp'],
        transaction_hash: callback_params['hash'],
        user_id: user.id,
        conf_year: ApplicationSetting.get_current_app_year
      }
    end

    def reject_callback(reason)
      record_callback('rejected', nil, nil, reason)
      Result.new(status: :forbidden, payment: nil)
    end

    def record_callback(status, user = nil, payment = nil, reason = nil)
      PaymentGatewayCallback.create(
        user: user,
        payment: payment,
        transaction_id: transaction_id,
        processing_status: status,
        event_type: 'receipt',
        failure_reason: reason,
        payload: callback_params
      )
    end
  end
end
