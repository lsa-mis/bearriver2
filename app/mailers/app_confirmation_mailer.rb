class AppConfirmationMailer < ApplicationMailer

  def application_submitted
    @application = params[:app]
    @current_application_settings = ApplicationSetting.get_current_app_settings
    mail(to: @application.email, subject: "Your #{@current_application_settings.contest_year} Bear River Writers’ Conference application has been received.")
  end
end
