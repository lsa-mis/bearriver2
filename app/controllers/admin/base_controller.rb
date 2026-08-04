require 'csv'

module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin_user!
    layout 'admin'

    helper_method :admin_nav_sections

    private

    def admin_nav_sections
      [
        {
          title: nil,
          items: [
            { label: 'Dashboard', path: admin_root_path }
          ]
        },
        {
          title: 'User Management',
          items: [
            { label: 'Applications', path: admin_applications_path },
            { label: 'Payments', path: admin_payments_path },
            { label: 'Gateway callbacks', path: admin_payment_gateway_callbacks_path },
            { label: 'Users', path: admin_users_path }
          ]
        },
        {
          title: 'Application Configuration',
          items: [
            { label: 'Application Settings', path: admin_application_settings_path },
            { label: 'Genders', path: admin_genders_path },
            { label: 'Lodgings', path: admin_lodgings_path },
            { label: 'Partner Registrations', path: admin_partner_registrations_path },
            { label: 'Workshops', path: admin_workshops_path }
          ]
        },
        {
          title: 'Admin',
          items: [
            { label: 'Admin Users', path: admin_admin_users_path }
          ]
        }
      ]
    end

    def send_csv(filename:, headers:, rows:)
      csv_data = CSV.generate(headers: true) do |csv|
        csv << headers
        rows.each { |row| csv << row }
      end
      send_data csv_data, filename: filename, type: 'text/csv'
    end
  end
end
