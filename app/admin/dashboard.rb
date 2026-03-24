ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }


  content title: proc { I18n.t("active_admin.dashboard") } do

    if (current_application_settings.opendate + current_application_settings.application_open_period.hours) < Time.current
      if current_application_settings.lottery_result.nil?
        div do
          span do
            button_to "Run Lottery", run_lotto_path
          end
        end
      end
    end

    # Only special payment invitees (not scholarship or other account types).
    special_invitees = Payment.current_conference_payments
                              .where(account_type: 'special')
                              .includes(:user)
                              .order(created_at: :desc, id: :desc)
                              .group_by(&:user_id)
                              .map { |_user_id, payments| payments.first }
                              .sort_by { |payment| payment.user.email.to_s.downcase }
    invitee_user_ids = special_invitees.map(&:user_id).uniq
    invitee_conf_years = special_invitees.map(&:conf_year).uniq
    latest_applications_by_user_and_year =
      Application.where(user_id: invitee_user_ids, conf_year: invitee_conf_years)
                 .order(created_at: :desc)
                 .each_with_object({}) do |application, apps_by_user_and_year|
        key = [application.user_id, application.conf_year]
        apps_by_user_and_year[key] ||= application
      end

    columns do
      column do
        current_year_applications_scope = Application.active_conference_applications
        current_year_application_count = current_year_applications_scope.count
        recent_applications = current_year_applications_scope.order(created_at: :desc).limit(25)

        panel "Latest 25 of #{current_year_application_count} Applications for the #{ApplicationSetting.get_current_app_year} conference" do
          table_for recent_applications do
            column(:id) { |app| link_to(app.display_name, admin_application_path(app)) }
          end
          div do
            link_to 'See all current applications', admin_applications_path(q: { applications_conf_year_eq: ApplicationSetting.get_current_app_year })
          end
        end
      end

      column do
        panel "Special invitees (#{special_invitees.size})" do
          table_for special_invitees do
            column('Email Address') { |payment| payment.user.email }
            column('Application Status') do |payment|
              application = latest_applications_by_user_and_year[[payment.user_id, payment.conf_year]]

              if application.present?
                full_name = "#{application.first_name} #{application.last_name}".squish
                link_to(full_name, admin_application_path(application))
              else
                "Needs to submit an application to #{ApplicationSetting.get_current_app_year}"
              end
            end
            column('Account Type') { |payment| payment.account_type }
          end
        end
      end

      column do
        panel "Recent Payments" do
          table_for Payment.current_conference_payments.sort.reverse.first(10) do
            column("Name") do |a|
              if a.user.current_conf_application.present?
                link_to a.user.current_conf_application.display_name, admin_application_path(a.user.current_conf_application)
              else
                "#{a.user.email} ( - waiting for application to be submitted)"
              end
            end
            column("Type") { |a| link_to(a.account_type, admin_payment_path(a)) }
            column("Amount") { |a| number_to_currency a.total_amount.to_f / 100 }
          end
        end
      end
    end

    begin
      columns do
        if current_application_settings.respond_to?(:allow_payments?) && current_application_settings.allow_payments?
          div do
            span do
              button_to 'Send Balance Due email', send_balance_due_url, class: 'btn'
            end
          end
        end
        column do
          accepted_applications = Application.application_accepted
          accepted_count = accepted_applications.respond_to?(:count) ? accepted_applications.count : 0
          panel "#{ApplicationSetting.get_current_app_year} Applicants who accepted their offer (#{accepted_count})" do
            applications =
              if accepted_applications.respond_to?(:includes)
                accepted_applications.includes(:partner_registration).sort.reverse
              else
                Array(accepted_applications).select { |app| app.respond_to?(:display_name) }
              end
            raw_payments = Payment.where(transaction_status: '1').group(:user_id, :conf_year).sum(Arel.sql("total_amount::numeric"))
            payments_totals = raw_payments.transform_keys { |k| [k[0].to_i, k[1].to_i] }
            lodgings_by_desc = Lodging.all.index_by(&:description)
            table_for applications do
              column("Applicant") { |u| link_to(u.display_name, admin_application_path(u.id)) }
              column("Offer Date") { |od| od.offer_status_date }
              column("Balance Due") { |a| number_to_currency(a.balance_due_with_batch(payments_totals: payments_totals, lodgings_by_desc: lodgings_by_desc)) }
            end
          end
        end

        column do
          offered_applications = Application.application_offered
          offered_count = offered_applications.respond_to?(:count) ? offered_applications.count : 0
          panel "Waiting for responses from these #{ApplicationSetting.get_current_app_year} applicants (#{offered_count})" do
            applications =
              if offered_applications.respond_to?(:sort)
                offered_applications.sort.reverse
              else
                Array(offered_applications).select { |app| app.respond_to?(:user) }
              end
            table_for applications do
              column("User") { |u| link_to(u.user.email, admin_application_path(u.id)) }
              column("Offer Date") { |od| od.offer_status_date }
            end
          end
        end
      end # columns
    rescue NoMethodError
    end
    div do
      span do
        link_to 'Admin Documentation', 'https://docs.google.com/document/d/1_FS9pUxsBbl7o8tDFY9-15XcwpqBMzsZFhGoJQLMwVg/edit?usp=sharing', target: '_blank', class: 'btn'
      end
    end
    div do
      h2 do
        'These are the items to check when setting up a new conference:'
      end
      ul do
        li do
          span do
            link_to 'Create new conference instance', 'https://bearriver.lsa.umich.edu/admin/application_settings'
          end
          span do
            link_to 'See details', 'https://docs.google.com/document/d/1_FS9pUxsBbl7o8tDFY9-15XcwpqBMzsZFhGoJQLMwVg/edit?tab=t.0#heading=h.3eb37iahpogi',
            target: '_blank'
          end
        end
        li do
          span do
            link_to 'Check the pricing for lodging costs', 'https://bearriver.lsa.umich.edu/admin/lodgings'
          end
        end
        li do
          span do
            link_to 'Check the pricing for the partner registration costs', 'https://bearriver.lsa.umich.edu/admin/partner_registrations'
          end
        end
        li do
          span do
            link_to 'Check the workshops being offered', 'https://bearriver.lsa.umich.edu/admin/workshops'
          end
        end
      end
    end
  end # content
end
