module Admin
  class DashboardController < BaseController
    def show
      @settings = current_application_settings
      @current_year = ApplicationSetting.get_current_app_year

      current_year_scope = Application.active_conference_applications
      @current_year_application_count = current_year_scope.count
      @recent_applications = current_year_scope.order(created_at: :desc).limit(25)

      @special_invitees = Payment.current_conference_payments
                                 .where(account_type: 'special')
                                 .includes(:user)
                                 .order(created_at: :desc, id: :desc)
                                 .group_by(&:user_id)
                                 .map { |_user_id, payments| payments.first }
                                 .sort_by { |payment| payment.user.email.to_s.downcase }

      invitee_user_ids = @special_invitees.map(&:user_id).uniq
      invitee_conf_years = @special_invitees.map(&:conf_year).uniq
      @latest_applications_by_user_and_year =
        Application.where(user_id: invitee_user_ids, conf_year: invitee_conf_years)
                   .order(created_at: :desc)
                   .each_with_object({}) do |application, apps_by_user_and_year|
          key = [application.user_id, application.conf_year]
          apps_by_user_and_year[key] ||= application
        end

      @recent_payments = Payment.current_conference_payments
                                .order(created_at: :desc)
                                .limit(10)
                                .includes(:user)
                                .to_a
      user_ids = @recent_payments.map(&:user_id).uniq
      @current_app_by_user_id =
        if user_ids.empty?
          {}
        else
          Application.where(user_id: user_ids, conf_year: @current_year)
                     .order(:user_id, :id)
                     .group_by(&:user_id)
                     .transform_values(&:last)
        end

      accepted_scope = Application.application_accepted
      @accepted_applications =
        if accepted_scope.respond_to?(:includes)
          accepted_scope.includes(:partner_registration).to_a.sort.reverse
        else
          Array(accepted_scope).select { |app| app.respond_to?(:display_name) }
        end

      raw_payments = Payment.where(transaction_status: '1').group(:user_id, :conf_year).sum(Arel.sql('total_amount::numeric'))
      @payments_totals = raw_payments.transform_keys { |k| [k[0].to_i, k[1].to_i] }
      @lodgings_by_desc = Lodging.all.index_by(&:description)

      offered_scope = Application.application_offered
      @offered_applications =
        if offered_scope.respond_to?(:includes)
          offered_scope.includes(:user).to_a.sort.reverse
        else
          Array(offered_scope).select { |app| app.respond_to?(:user) }
        end

      @show_lottery_button = @settings.present? &&
                             (@settings.opendate + @settings.application_open_period.hours) < Time.current &&
                             @settings.lottery_result.nil?
    end
  end
end
