require 'rails_helper'

RSpec.describe 'Admin Applications Show', type: :request do
  let(:admin_user) { create(:admin_user) }
  let!(:application_setting) do
    create(:application_setting, contest_year: Time.current.year, active_application: true)
  end

  def currency(amount)
    ActionController::Base.helpers.number_to_currency(amount)
  end

  context 'without subscription' do
    it 'computes ttl_paid and total_cost correctly' do
      sign_in admin_user

      user = create(:user)
      lodging = create(:lodging, cost: 100.0, description: 'Standard')
      partner_registration = create(:partner_registration, cost: 50.0)

      application = create(
        :application,
        user: user,
        conf_year: application_setting.contest_year,
        lodging_selection: lodging.description,
        partner_registration: partner_registration,
        subscription: false
      )

      # Two settled payments totaling $30.00 (in cents)
      create(
        :payment,
        user: user,
        conf_year: application_setting.contest_year,
        transaction_status: '1',
        total_amount: '1000'
      )
      create(
        :payment,
        user: user,
        conf_year: application_setting.contest_year,
        transaction_status: '1',
        total_amount: '2000'
      )

      expected_ttl_paid = 30.0
      expected_total_cost = 100.0 + 50.0
      expected_balance_due = expected_total_cost - expected_ttl_paid

      get admin_application_path(application)
      expect(response).to be_successful

      expect(response.body).to include("Balance Due: #{currency(expected_balance_due)} Total Cost: #{currency(expected_total_cost)}")
    end
  end

  context 'with subscription' do
    it 'includes subscription cost in total_cost and uses ttl_paid correctly' do
      sign_in admin_user

      user = create(:user)
      lodging = create(:lodging, cost: 100.0, description: 'Standard')
      partner_registration = create(:partner_registration, cost: 50.0)

      application = create(
        :application,
        user: user,
        conf_year: application_setting.contest_year,
        lodging_selection: lodging.description,
        partner_registration: partner_registration,
        subscription: true
      )

      # Two settled payments totaling $30.00 (in cents)
      create(
        :payment,
        user: user,
        conf_year: application_setting.contest_year,
        transaction_status: '1',
        total_amount: '1000'
      )
      create(
        :payment,
        user: user,
        conf_year: application_setting.contest_year,
        transaction_status: '1',
        total_amount: '2000'
      )

      subscription_cost = application_setting.subscription_cost.to_f
      expected_ttl_paid = 30.0
      expected_total_cost = 100.0 + 50.0 + subscription_cost
      expected_balance_due = expected_total_cost - expected_ttl_paid

      get admin_application_path(application)
      expect(response).to be_successful

      expect(response.body).to include("Balance Due: #{currency(expected_balance_due)} Total Cost: #{currency(expected_total_cost)}")
    end
  end
end

