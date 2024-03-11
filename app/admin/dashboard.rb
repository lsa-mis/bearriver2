ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  
  content title: proc { I18n.t("active_admin.dashboard") } do

    if (current_application_settings.opendate + current_application_settings.application_open_period.hours) < Time.now
      if current_application_settings.lottery_result.nil?
        div do
          span do
            button_to "Run Lottery", run_lotto_path
          end
        end
      end
    end

    columns do
      column do
        panel "Recent #{ApplicationSetting.get_current_app_year} Applications" do
          table_for Application.active_conference_applications.sort.reverse.first(10) do
            column(:id) { |app| link_to(app.display_name, admin_application_path(app)) }
          end
        end
      end

      column do
        panel "Recent Payments" do
          table_for Payment.current_conference_payments.sort.reverse.first(10) do
            # column("Name") { |a| link_to(a.user.current_conf_application.name, admin_payment_path(a)) if a.user.current_conf_application.present? }
            column("Name") { |a| link_to(a.user.current_conf_application.name, admin_payment_path(a)) if a.user.current_conf_application.present? } 
            column("eMail") { |a| link_to(a.user.email, admin_payment_path(a)) }
            column("Type") { |a| link_to(a.account_type, admin_payment_path(a)) } 
            column("Amount") { |a| number_to_currency a.total_amount.to_f / 100 }
          end
        end
      end

    end

    columns do
      if current_application_settings.allow_payments?
        div do
          span do
            button_to 'Send Balance Due email', send_balance_due_url, class: 'btn'
          end
        end
      end
      column do
        panel "#{ApplicationSetting.get_current_app_year} Applicants who accepted their offer (#{Application.application_accepted.count})" do
          table_for Application.application_accepted.sort.reverse do
            column("Applicant") { |u| link_to(u.display_name, admin_application_path(u.id)) }
            column("Offer Date") { |od| od.offer_status_date }
            column("Balance Due") { |a| number_to_currency a.balance_due }  
          end
        end
      end

      column do
        panel "Waiting for responses from these #{ApplicationSetting.get_current_app_year} applicants (#{Application.application_offered.count})" do
          table_for Application.application_offered.sort.reverse do
            column("User") { |u| link_to(u.user.email, admin_application_path(u.id)) }
            column("Offer Date") { |od| od.offer_status_date }
          end
        end
      end
    end # columns
    div do
      span do
        link_to 'Admin Documentation', 'https://docs.google.com/document/d/1_FS9pUxsBbl7o8tDFY9-15XcwpqBMzsZFhGoJQLMwVg/edit?usp=sharing', target: '_blank', class: 'btn'
      end
    end
  end # content
end
