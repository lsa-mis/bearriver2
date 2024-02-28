module PaymentsHelper
  def format_total_payment(current_payment)
      number_to_currency(current_payment.total_amount.to_f / 100 )
  end

end