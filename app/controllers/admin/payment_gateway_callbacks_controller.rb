module Admin
  class PaymentGatewayCallbacksController < BaseController
    before_action :set_callback, only: :show

    def index
      @callbacks = PaymentGatewayCallback.includes(:user, :payment).order(created_at: :desc)
      @callbacks = @callbacks.where(transaction_id: params[:transaction_id]) if params[:transaction_id].present?
      @callbacks = @callbacks.where(processing_status: params[:processing_status]) if params[:processing_status].present?
      @callbacks = @callbacks.where(event_type: params[:event_type]) if params[:event_type].present?
      @callbacks = @callbacks.where(user_id: params[:user_id]) if params[:user_id].present?
      @callbacks = @callbacks.where(payment_id: params[:payment_id]) if params[:payment_id].present?
    end

    def show
    end

    private

    def set_callback
      @callback = PaymentGatewayCallback.find(params[:id])
    end
  end
end
