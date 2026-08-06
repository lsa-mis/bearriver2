class ApplicationController < ActionController::Base
  # Must run before Devise/Warden and CSRF read credentials from request.params.
  prepend_before_action :strip_null_bytes_from_params

  private

  def strip_null_bytes_from_params
    sanitize_param_object!(request.request_parameters) if request.request_parameters.present?
    sanitize_param_object!(request.query_parameters) if request.query_parameters.present?

    # Drop any memoized merge built before this filter so Devise strategies
    # (which read request.params) see the sanitized values.
    request.delete_header('action_dispatch.request.parameters')
    @_params = nil
  end

  def sanitize_param_object!(value)
    case value
    when String
      value.delete!("\u0000")
      value
    when Array
      value.map! { |item| sanitize_param_object!(item) }
    when ActionController::Parameters
      # Sanitize both keys and values.
      value.keys.each do |key|
        item = value.delete(key)
        sanitized_key = key.to_s.delete("\u0000")
        value[sanitized_key] = sanitize_param_object!(item)
      end
      value
    when Hash
      # Sanitize both keys and values, preserving Symbol keys.
      value.keys.each do |key|
        item = value.delete(key)
        sanitized_key_string = key.to_s.delete("\u0000")
        sanitized_key = key.is_a?(Symbol) ? sanitized_key_string.to_sym : sanitized_key_string
        value[sanitized_key] = sanitize_param_object!(item)
      end
      value
    else
      value
    end
  end

  def current_application_settings
    @current_application_settings ||= ApplicationSetting.get_current_app_settings
  end

  helper_method :current_application_settings

  def current_application_open?
    if current_application_settings
      start_time = current_application_settings.opendate
      end_time = start_time + current_application_settings.application_open_period.hours
      range = start_time..end_time
      range.cover?(Time.current)
    else
      false
    end
  end

  helper_method :current_application_open?

  def user_has_application?(user)
    if Application.active_conference_applications.find_by(user_id: user).nil?
      false
    else
      true
    end
  end

  helper_method :user_has_application?

  def user_has_special_payment?(user)
    if Payment.current_conference_payments.where(user_id: user).where(account_type: ["scholarship", "special"]).any?
      true
    else
      false
    end
  end

  helper_method :user_has_special_payment?

  def user_has_payments?(user)
    # return true unless Payment.find_by(user_id: user).nil?
    if Payment.current_conference_payments.find_by(user_id: user).nil?
      false
    else
      true
    end
  end

  helper_method :user_has_payments?

  def payments_open?
    current_application_settings.allow_payments
  end

  helper_method :payments_open?

  def get_workshops
    @workshops_available = Workshop.active.order_by_lastname
  end

  helper_method :get_workshops

  def get_lodgings
    @lodgings = Lodging.all
  end

  helper_method :get_lodgings

  def get_partner_registrations
    @partner_registrations = PartnerRegistration.active.order(cost: :asc)
  end

  helper_method :get_partner_registrations

end
