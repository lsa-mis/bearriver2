class BalanceDueMailer < ApplicationMailer

  def outstanding_balance
    @application = params[:app]
    @current_application_settings = ApplicationSetting.get_current_app_settings
    mail(to: @application.email, subject: "Your #{@current_application_settings.contest_year} Bear River Writers’ Conference payment due notification.")
  end
end
