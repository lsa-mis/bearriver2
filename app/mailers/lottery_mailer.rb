class LotteryMailer < ApplicationMailer

  def won_lottery_email
    @application = params[:application]
    @current_application_settings = ApplicationSetting.get_current_app_settings
    @lottery_won_mail_body = @current_application_settings.lottery_won_email
    mail(to: @application.email, subject: "You have been selected by lottery for a place in the 
      #{@current_application_settings.contest_year} Bear River Writers’ Conference.")
  end

  def pre_lottery_offer_email
    @application = params[:application]
    @current_application_settings = ApplicationSetting.get_current_app_settings
    @special_offer_invite_email_body = @current_application_settings.special_offer_invite_email
    mail(to: @application.email, subject: "You have been selected for a place in the 
      #{@current_application_settings.contest_year} Bear River Writers’ Conference.")
  end

  def waitlisted_offer_email
    @application = params[:application]
    @current_application_settings = ApplicationSetting.get_current_app_settings
    @special_offer_invite_email_body = @current_application_settings.special_offer_invite_email
    mail(to: @application.email, subject: "You have been selected for a place in the 
      #{@current_application_settings.contest_year} Bear River Writers’ Conference.")
  end

  def lost_lottery_email  
    @application = params[:application]
    @current_application_settings = ApplicationSetting.get_current_app_settings
    @lottery_lost_mail_body = @current_application_settings.lottery_lost_email
    mail(to: @application.email, subject: "#{@current_application_settings.contest_year} Bear River Writers’ Conference lottery result")
  end
end
