module Admin
  class ApplicationSettingsController < BaseController
    before_action :set_application_setting, only: %i[show edit update destroy]

    def index
      @application_settings = ApplicationSetting.order(contest_year: :desc)
    end

    def show
    end

    def edit
    end

    def update
      if @application_setting.update(application_setting_params)
        redirect_to admin_application_setting_path(@application_setting), notice: 'Application setting was successfully updated.'
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @application_setting.destroy
      redirect_to admin_application_settings_path, notice: 'Application setting was successfully deleted.'
    end

    def duplicate
      source = ApplicationSetting.order(:contest_year).last
      if source.nil?
        redirect_to admin_application_settings_path, alert: 'No application settings to duplicate.'
        return
      end

      new_setting = source.dup.tap do |setting|
        setting.contest_year = source.contest_year + 1
        setting.active_application = false
        setting.lottery_result = nil
        setting.lottery_run_date = nil
        setting.allow_payments = false
        setting.balance_due_emails_last_sent_at = nil
      end
      new_setting.save!
      redirect_to admin_application_settings_path, notice: 'Conference setting duplicated.'
    end

    def run_lottery
      settings = current_application_settings
      if settings.nil?
        redirect_to admin_root_path, alert: 'No active application settings.'
        return
      end

      unless (settings.opendate + settings.application_open_period.hours) < Time.current
        redirect_to admin_root_path, alert: 'Application period is still open.'
        return
      end

      if settings.lottery_result.present?
        redirect_to admin_root_path, alert: 'The lottery has already been run'
        return
      end

      active_applications_ids = Application.entries_included_in_lottery.pluck(:id)
      3.times { active_applications_ids.shuffle! }
      settings.update(lottery_result: active_applications_ids, lottery_run_date: Time.current)

      settings.lottery_result.each_with_index do |item, idx|
        app = Application.find(item)
        if idx < settings.lottery_buffer
          app.update(lottery_position: idx, offer_status: 'registration_offered', offer_status_date: Time.current, result_email_sent: true)
          LotteryMailer.with(application: app).won_lottery_email.deliver_now
        else
          app.update(lottery_position: idx, offer_status: 'not_offered', offer_status_date: Time.current, result_email_sent: true)
          LotteryMailer.with(application: app).lost_lottery_email.deliver_now
        end
      end
      send_pre_lottery_selected_emails
      redirect_to admin_root_path, notice: 'The lottery was successfully run.'
    end

    private

    def send_pre_lottery_selected_emails
      pre_offers = Application.active_conference_applications.where(offer_status: 'special_offer_application', result_email_sent: false)
      pre_offers.each do |pre_offer_app|
        pre_offer_app.update(offer_status: 'registration_offered', offer_status_date: Time.current, result_email_sent: true)
        LotteryMailer.with(application: pre_offer_app).pre_lottery_offer_email.deliver_now
      end
    end

    def set_application_setting
      @application_setting = ApplicationSetting.find(params[:id])
    end

    def application_setting_params
      params.require(:application_setting).permit(
        :opendate, :application_buffer, :contest_year, :time_zone, :allow_payments,
        :active_application, :allow_lottery_winner_emails, :allow_lottery_loser_emails,
        :registration_fee, :lottery_buffer, :application_open_directions,
        :application_closed_directions, :application_open_period,
        :registration_acceptance_directions, :special_scholarship_acceptance_directions,
        :payments_directions, :application_confirm_email_message, :balance_due_email_message,
        :lottery_won_email, :special_offer_invite_email, :lottery_lost_email,
        :subscription_cost, :subscription_directions
      )
    end
  end
end
