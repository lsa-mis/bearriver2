require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  let(:user) { create(:user) }
  let(:admin_user) { create(:admin_user) }
  let(:application) { create(:application, user: user) }
  let(:application_setting) { create(:application_setting, active_application: true) }
  let(:lodging) { create(:lodging, description: application.lodging_selection, cost: 150.0) }
  let(:partner_registration) { create(:partner_registration, cost: 75.0) }
  let(:payment) { create(:payment, user: user) }

  before do
    # Set up application settings
    application_setting
    # Set up associated records
    lodging
    partner_registration
    application.update!(partner_registration: partner_registration)
  end

  describe 'GET #index' do
    context 'when user is authenticated' do
      before { sign_in user }

      it 'redirects to root_url' do
        get :index
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST #payment_receipt' do
    let(:valid_params) do
      {
        transactionType: 'Credit',
        transactionStatus: '1',
        transactionId: 'test_transaction_123',
        transactionTotalAmount: '10000',
        transactionDate: '202401011200',
        transactionAcountType: 'registration',
        transactionResultCode: '0',
        transactionResultMessage: 'Approved',
        orderNumber: 'testuser-123',
        timestamp: Time.current.to_i.to_s,
        hash: 'valid_hash_here'
      }
    end

    context 'when user is authenticated' do
      before { sign_in user }

      context 'with valid payment callback parameters' do
        context 'when transaction_id does not exist' do
          it 'creates a new payment record' do
            expect {
              post :payment_receipt, params: valid_params
            }.to change(Payment, :count).by(1)
          end

          it 'updates application offer_status to registration_accepted' do
            post :payment_receipt, params: valid_params
            expect(application.reload.offer_status).to eq('registration_accepted')
          end

          it 'redirects to all_payments_path with success notice' do
            post :payment_receipt, params: valid_params
            expect(response).to redirect_to(all_payments_path)
            expect(flash[:notice]).to eq('Your Payment Was Successfully Recorded')
          end

          it 'creates payment with correct attributes' do
            post :payment_receipt, params: valid_params
            payment = Payment.last
            expect(payment.transaction_type).to eq('Credit')
            expect(payment.transaction_status).to eq('1')
            expect(payment.transaction_id).to eq('test_transaction_123')
            expect(payment.total_amount).to eq('10000')
            expect(payment.user_id).to eq(user.id)
            expect(payment.payer_identity).to eq(user.email)
            expect(payment.conf_year).to eq(ApplicationSetting.get_current_app_year)
          end
        end

        context 'when transaction_id already exists' do
          before do
            create(:payment, transaction_id: 'test_transaction_123')
          end

          it 'does not create a new payment record' do
            expect {
              post :payment_receipt, params: valid_params
            }.not_to change(Payment, :count)
          end

          it 'redirects to all_payments_path' do
            post :payment_receipt, params: valid_params
            expect(response).to redirect_to(all_payments_path)
          end
        end
      end

      context 'with missing required parameters' do
        it 'returns forbidden status when hash is missing' do
          post :payment_receipt, params: valid_params.except(:hash)
          expect(response).to have_http_status(:forbidden)
        end

        it 'returns forbidden status when timestamp is missing' do
          post :payment_receipt, params: valid_params.except(:timestamp)
          expect(response).to have_http_status(:forbidden)
        end

        it 'returns forbidden status when transactionId is missing' do
          post :payment_receipt, params: valid_params.except(:transactionId)
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        post :payment_receipt, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST #make_payment' do
    let(:amount) { '100' }

    context 'when user is authenticated' do
      before { sign_in user }

      it 'redirects to generated payment URL' do
        post :make_payment, params: { amount: amount }
        expect(response).to be_redirect
        expect(response.location).to include('orderNumber=')
        expect(response.location).to include('amountDue=')
        expect(response.location).to include('hash=')
      end

      it 'generates URL with correct user account format' do
        post :make_payment, params: { amount: amount }
        expect(response.location).to include("orderNumber=#{user.email.partition('@').first}-#{user.id}")
      end

      it 'generates URL with correct amount in cents' do
        post :make_payment, params: { amount: amount }
        expect(response.location).to include('amountDue=10000') # 100 * 100
      end

      context 'with different amounts' do
        it 'handles decimal amounts correctly' do
          post :make_payment, params: { amount: '50.50' }
          expect(response.location).to include('amountDue=5000') # 50.50.to_i * 100 = 50 * 100
        end

        it 'handles zero amount' do
          post :make_payment, params: { amount: '0' }
          expect(response.location).to include('amountDue=0')
        end
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        post :make_payment, params: { amount: amount }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #payment_show' do
    context 'when user is authenticated' do
      before { sign_in user }

      context 'when user has payments' do
        let!(:payment1) { create(:payment, :current_conference, user: user, total_amount: '5000', transaction_status: '1') }
        let!(:payment2) { create(:payment, :current_conference, user: user, total_amount: '3000', transaction_status: '1') }

        it 'assigns @users_current_payments' do
          get :payment_show
          expect(assigns(:users_current_payments)).to include(payment1, payment2)
        end

        it 'calculates total paid correctly' do
          get :payment_show
          expect(assigns(:ttl_paid)).to eq(80.0) # (5000 + 3000) / 100
        end

        it 'calculates total cost correctly' do
          get :payment_show
          expect(assigns(:total_cost)).to eq(175.0) # 100 (lodging) + 75 (partner)
        end

        it 'calculates balance due correctly' do
          get :payment_show
          expect(assigns(:balance_due)).to eq(95.0) # 175 - 80
        end

        context 'with subscription' do
          before { application.update!(subscription: true) }

          it 'includes subscription cost in total' do
            get :payment_show
            expect(assigns(:total_cost)).to eq(200.0) # 100 + 75 + 25 (subscription)
          end
        end

        context 'without subscription' do
          before { application.update!(subscription: false) }

          it 'does not include subscription cost in total' do
            get :payment_show
            expect(assigns(:total_cost)).to eq(175.0) # 100 + 75
          end
        end
      end

      context 'when user has no payments' do
        it 'redirects to root_url' do
          get :payment_show
          expect(response).to redirect_to(root_url)
        end
      end

      context 'when user has payments but none are settled' do
        let!(:payment) { create(:payment, :current_conference, user: user, transaction_status: '0') }

        it 'calculates total paid as zero' do
          get :payment_show
          expect(assigns(:ttl_paid)).to eq(0.0)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in page' do
        get :payment_show
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE #delete_manual_payment' do
    let!(:payment) { create(:payment, :manual) }

    context 'when admin user is authenticated' do
      before { sign_in admin_user }

      it 'deletes the payment' do
        expect {
          delete :delete_manual_payment, params: { id: payment.id }
        }.to change(Payment, :count).by(-1)
      end

      it 'redirects to admin_payments_url with success notice' do
        delete :delete_manual_payment, params: { id: payment.id }
        expect(response).to redirect_to(admin_payments_url)
        expect(flash[:notice]).to eq('Payment was successfully deleted.')
      end

      it 'responds with no content for JSON format' do
        delete :delete_manual_payment, params: { id: payment.id }, format: :json
        expect(response).to have_http_status(:no_content)
      end

      context 'when payment does not exist' do
        it 'raises ActiveRecord::RecordNotFound' do
          expect {
            delete :delete_manual_payment, params: { id: 999999 }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'when regular user is authenticated' do
      before { sign_in user }

      it 'redirects to sign in page' do
        delete :delete_manual_payment, params: { id: payment.id }
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end

    context 'when no user is authenticated' do
      it 'redirects to sign in page' do
        delete :delete_manual_payment, params: { id: payment.id }
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end

  describe 'private methods' do
    describe '#verify_payment_callback' do
      context 'with all required parameters' do
        it 'does not return forbidden status' do
          # Test through the public interface
          post :payment_receipt, params: {
            hash: 'valid_hash',
            timestamp: '1234567890',
            transactionId: 'test_123',
            transactionType: 'Credit',
            transactionStatus: '1',
            transactionTotalAmount: '10000',
            transactionDate: '202401011200',
            transactionAcountType: 'registration',
            transactionResultCode: '0',
            transactionResultMessage: 'Approved',
            orderNumber: 'testuser-123'
          }
          expect(response).not_to have_http_status(:forbidden)
        end
      end

      context 'with missing hash' do
        it 'returns forbidden status' do
          post :payment_receipt, params: {
            timestamp: '1234567890',
            transactionId: 'test_123',
            transactionType: 'Credit',
            transactionStatus: '1',
            transactionTotalAmount: '10000',
            transactionDate: '202401011200',
            transactionAcountType: 'registration',
            transactionResultCode: '0',
            transactionResultMessage: 'Approved',
            orderNumber: 'testuser-123'
          }
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'with missing timestamp' do
        it 'returns forbidden status' do
          post :payment_receipt, params: {
            hash: 'valid_hash',
            transactionId: 'test_123',
            transactionType: 'Credit',
            transactionStatus: '1',
            transactionTotalAmount: '10000',
            transactionDate: '202401011200',
            transactionAcountType: 'registration',
            transactionResultCode: '0',
            transactionResultMessage: 'Approved',
            orderNumber: 'testuser-123'
          }
          expect(response).to have_http_status(:forbidden)
        end
      end

      context 'with missing transactionId' do
        it 'returns forbidden status' do
          post :payment_receipt, params: {
            hash: 'valid_hash',
            timestamp: '1234567890',
            transactionType: 'Credit',
            transactionStatus: '1',
            transactionTotalAmount: '10000',
            transactionDate: '202401011200',
            transactionAcountType: 'registration',
            transactionResultCode: '0',
            transactionResultMessage: 'Approved',
            orderNumber: 'testuser-123'
          }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    describe '#generate_hash' do
      before { sign_in user }

      context 'in development environment' do
        before do
          allow(Rails.env).to receive(:development?).and_return(true)
          allow(Rails.application.credentials).to receive(:NELNET_SERVICE).and_return({
            DEVELOPMENT_KEY: 'dev_key',
            DEVELOPMENT_URL: 'https://dev.example.com',
            PRODUCTION_KEY: 'prod_key',
            PRODUCTION_URL: 'https://prod.example.com'
          })
        end

        it 'uses development credentials' do
          post :make_payment, params: { amount: '100' }
          expect(response.location).to include('https://dev.example.com')
        end
      end

      context 'in production environment' do
        before do
          allow(Rails.env).to receive(:development?).and_return(false)
          allow(Rails.env).to receive(:staging?).and_return(false)
          allow(Rails.application.credentials).to receive(:NELNET_SERVICE).and_return({
            SERVICE_SELECTOR: 'PROD',
            DEVELOPMENT_KEY: 'dev_key',
            DEVELOPMENT_URL: 'https://dev.example.com',
            PRODUCTION_KEY: 'prod_key',
            PRODUCTION_URL: 'https://prod.example.com'
          })
        end

        it 'uses production credentials' do
          post :make_payment, params: { amount: '100' }
          expect(response.location).to include('https://prod.example.com')
        end
      end

      it 'generates URL with correct parameters' do
        post :make_payment, params: { amount: '100' }
        expect(response.location).to include('orderNumber=')
        expect(response.location).to include('orderType=English Department Online')
        expect(response.location).to include('orderDescription=Bearriver Conference Fees')
        expect(response.location).to include('amountDue=10000')
        expect(response.location).to include('hash=')
      end

      it 'creates user account in correct format' do
        post :make_payment, params: { amount: '100' }
        expected_account = "#{user.email.partition('@').first}-#{user.id}"
        expect(response.location).to include("orderNumber=#{expected_account}")
      end
    end

    describe '#current_application' do
      before { sign_in user }

      it 'finds the current user\'s active conference application' do
        app = controller.send(:current_application)
        expect(app).to eq(application)
      end
    end
  end

  describe 'authentication and authorization' do
    describe 'before_action filters' do
      it 'skips verify_authenticity_token for payment_receipt' do
        # Test that payment_receipt can be called without CSRF token
        post :payment_receipt, params: {
          transactionType: 'Credit',
          transactionStatus: '1',
          transactionId: 'test_transaction_123',
          transactionTotalAmount: '10000',
          transactionDate: '202401011200',
          transactionAcountType: 'registration',
          transactionResultCode: '0',
          transactionResultMessage: 'Approved',
          orderNumber: 'testuser-123',
          timestamp: Time.current.to_i.to_s,
          hash: 'valid_hash_here'
        }
        expect(response).not_to have_http_status(:unprocessable_entity)
      end

      it 'requires user authentication for most actions' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'requires admin authentication for delete_manual_payment' do
        delete :delete_manual_payment, params: { id: payment.id }
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end
end
