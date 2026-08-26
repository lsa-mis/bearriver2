# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Payments', type: :request, real_application_settings: true, no_application_mock: true do
  let(:admin_user) { create(:admin_user) }
  let!(:application_setting) do
    create(:application_setting, contest_year: Time.current.year, active_application: true)
  end
  let(:user) { create(:user) }
  let!(:payment) { create(:payment, :manual, user: user, conf_year: application_setting.contest_year, payer_identity: 'Pat Payer') }

  describe 'authentication' do
    it 'redirects guests to admin login' do
      get admin_payments_path
      expect(response).to redirect_to(new_admin_user_session_path)
    end
  end

  context 'when signed in' do
    before { sign_in admin_user }

    describe 'GET /admin/payments' do
      it 'lists current conference payments' do
        get admin_payments_path
        expect(response).to be_successful
        expect(response.body).to include(user.email).or include('Pat Payer')
      end

      it 'supports scope=all and filters' do
        get admin_payments_path, params: {
          scope: 'all',
          conf_year: application_setting.contest_year,
          payer_identity: 'Pat Payer',
          account_type: payment.account_type
        }
        expect(response).to be_successful
      end

      it 'filters by applicant name via applications join' do
        create(:lodging, description: 'Standard')
        create(:application, user: user, first_name: 'Pat', last_name: 'Payer', lodging_selection: 'Standard')
        get admin_payments_path, params: { last_name: 'Payer', first_name: 'Pat' }
        expect(response).to be_successful
      end

      it 'exports CSV' do
        get admin_payments_path(format: :csv)
        expect(response).to be_successful
        expect(response.content_type).to include('text/csv')
        expect(response.body).to include('User')
        expect(response.body).to include('Total Amount')
      end

      it 'neutralizes formula injection in exported CSV cells' do
        create(
          :payment,
          :manual,
          user: user,
          conf_year: application_setting.contest_year,
          account_type: '+Credit',
          result_message: '@SUM(A1:A10)'
        )

        get admin_payments_path(format: :csv)

        expect(response).to be_successful
        expect(response.body).to include("'+Credit")
        expect(response.body).to include("'@SUM(A1:A10)")
      end
    end

    describe 'GET /admin/payments/:id' do
      it 'shows payment details and related callbacks' do
        create(:payment_gateway_callback, payment: payment, user: user, transaction_id: payment.transaction_id)
        get admin_payment_path(payment)
        expect(response).to be_successful
        expect(response.body).to include(user.email)
      end

      it 'renders successfully when the payment has no associated user' do
        payment.update_columns(user_id: nil)

        get admin_payment_path(payment)

        expect(response).to be_successful
      end
    end

    describe 'GET /admin/payments/new' do
      it 'renders the manual payment form for a user' do
        get new_admin_payment_path, params: { user_id: user.id }
        expect(response).to be_successful
        expect(response.body).to include(user.email)
      end
    end

    describe 'POST /admin/payments' do
      it 'creates a manually entered payment' do
        expect {
          post admin_payments_path, params: {
            payment: {
              user_id: user.id,
              conf_year: application_setting.contest_year,
              total_amount: '125.50',
              transaction_date: Time.current.strftime('%m/%d/%Y'),
              account_type: 'scholarship'
            }
          }
        }.to change(Payment, :count).by(1)

        created = Payment.order(:id).last
        expect(created.transaction_type).to eq('ManuallyEntered')
        expect(created.result_message).to include(admin_user.email)
        expect(response).to redirect_to(admin_payment_path(created))
      end


      it 'ignores mass-assigned gateway fields when creating a manual payment' do

        expect {
          post admin_payments_path, params: {
            payment: {
              user_id: user.id,
              conf_year: application_setting.contest_year,

              total_amount: '80.00',
              transaction_date: Time.current.strftime('%m/%d/%Y'),
              account_type: 'scholarship',
              transaction_type: 'Credit',
              transaction_status: '0',

              transaction_id: 'attacker-txn',
              transaction_hash: 'attacker-hash',
              result_code: 'FORGED',
              result_message: 'forged message'
            }
          }
        }.to change(Payment, :count).by(1)

        created = Payment.order(:id).last
        expect(created.transaction_type).to eq('ManuallyEntered')
        expect(created.transaction_status).to eq('1')
        expect(created.result_code).to eq('Manually Entered')
        expect(created.result_message).to include(admin_user.email)
        expect(created.transaction_id).not_to eq('attacker-txn')
        expect(created.transaction_hash).not_to eq('attacker-hash')

      end

      it 're-renders on invalid data' do
        expect {
          post admin_payments_path, params: {
            payment: {
              user_id: user.id,
              total_amount: 'not-a-number',
              transaction_date: Time.current.strftime('%m/%d/%Y'),
              account_type: 'scholarship'
            }
          }
        }.not_to change(Payment, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe 'DELETE /admin/payments/:id' do
      it 'deletes manually entered payments' do
        expect {
          delete admin_payment_path(payment)
        }.to change(Payment, :count).by(-1)
        expect(response).to redirect_to(admin_payments_path)
      end

      it 'refuses to delete gateway payments' do
        gateway_payment = create(:payment, user: user, transaction_type: 'Credit')
        expect {
          delete admin_payment_path(gateway_payment)
        }.not_to change(Payment, :count)
        expect(response).to redirect_to(admin_payment_path(gateway_payment))
        follow_redirect!
        expect(response.body).to include('Only manually entered payments can be deleted')
      end
    end
  end
end
