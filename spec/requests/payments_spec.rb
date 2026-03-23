require 'rails_helper'

RSpec.describe "Payments", type: :request do
  let(:user) { create(:user) }
  let(:admin_user) { create(:admin_user) }
  let(:application) { create(:application, user: user) }
  let(:payment) { create(:payment, user: user) }

  describe "GET /payments" do
    it "redirects to root_url" do
      sign_in user
      get payments_path
      expect(response).to redirect_to(root_url)
    end
  end

  describe "GET /payments/payment_show" do
    context "when user is not signed in" do
      it "redirects to sign in page" do
        get all_payments_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in but has no payments" do
      before do
        sign_in user
        allow_any_instance_of(PaymentsController).to receive(:user_has_payments?).and_return(false)
      end
    end

    context "when user is signed in and has payments" do
      before do
        sign_in user
        allow_any_instance_of(PaymentsController).to receive(:user_has_payments?).and_return(true)
        allow_any_instance_of(PaymentsController).to receive(:payments_open?).and_return(true)
        allow_any_instance_of(PaymentsController).to receive(:current_application) do |controller|
          controller.instance_variable_set(:@current_application, application)
        end
        create(:lodging, description: application.lodging_selection, cost: 100.0)
        application.update!(partner_registration: create(:partner_registration, cost: 0.0), subscription: false)
        create(:payment, :current_conference, user: user, transaction_status: '1', total_amount: '3000')

        allow_any_instance_of(PaymentsController).to receive(:current_application_settings).and_return(
          double(subscription_cost: 25.0, payments_directions: 'Payment instructions', allow_payments: true)
        )
      end

      it "renders helper text explaining partial payments" do
        get all_payments_path
        expect(response.body).to include("The amount is prefilled with your full balance due, but you can enter a different amount to make a partial payment.")
      end
    end
  end

  describe "POST /payments/make_payment" do
    context "when user is not signed in" do
      it "redirects to sign in page" do
        post make_payment_path, params: { amount: "100" }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in" do
      before do
        sign_in user
        allow_any_instance_of(PaymentsController).to receive(:current_application) do |controller|
          controller.instance_variable_set(:@current_application, application)
        end
        create(:lodging, description: application.lodging_selection, cost: 300.0)
        application.update!(partner_registration: create(:partner_registration, cost: 0.0), subscription: false)
        allow_any_instance_of(PaymentsController).to receive(:current_application_settings).and_return(
          double(subscription_cost: 25.0)
        )
        allow_any_instance_of(PaymentsController).to receive(:current_balance_due).and_return(300.0)
        allow_any_instance_of(PaymentsController).to receive(:generate_hash).and_return("https://payment-url.example.com")
      end

      it "redirects to the payment URL" do
        post make_payment_path, params: { amount: "100" }
        expect(response).to redirect_to("https://payment-url.example.com")
      end

      it "supports paying the full balance amount" do
        expect_any_instance_of(PaymentsController)
          .to receive(:generate_hash).with(user, 200).and_return("https://payment-url.example.com")

        post make_payment_path, params: { amount: "200" }
        expect(response).to redirect_to("https://payment-url.example.com")
      end

      it "supports paying a partial balance amount" do
        expect_any_instance_of(PaymentsController)
          .to receive(:generate_hash).with(user, 75).and_return("https://payment-url.example.com")

        post make_payment_path, params: { amount: "75" }
        expect(response).to redirect_to("https://payment-url.example.com")
      end

      it "rejects missing amount input" do
        post make_payment_path, params: { amount: "" }
        expect(response).to redirect_to(all_payments_path)
        expect(flash[:alert]).to eq("Please enter a valid payment amount.")
      end

      it "rejects non-numeric amount input" do
        post make_payment_path, params: { amount: "abc" }
        expect(response).to redirect_to(all_payments_path)
        expect(flash[:alert]).to eq("Please enter a valid payment amount.")
      end

      it "rejects non-positive amount input" do
        post make_payment_path, params: { amount: "0" }
        expect(response).to redirect_to(all_payments_path)
        expect(flash[:alert]).to eq("Please enter a valid payment amount.")
      end

      it "rejects amount above balance due" do
        post make_payment_path, params: { amount: "400" }
        expect(response).to redirect_to(all_payments_path)
        expect(flash[:alert]).to eq("Please enter a valid payment amount.")
      end
    end
  end

  describe "POST /payments/payment_receipt" do
    context "when payment verification fails" do
      it "returns forbidden status" do
        post payment_receipt_path
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when payment verification passes" do
      let(:payment_params) do
        {
          "hash" => "valid_hash",
          "timestamp" => Time.current.to_i.to_s,
          "transactionId" => "new_transaction_id",
          "transactionType" => "Credit",
          "transactionStatus" => "1",
          "transactionTotalAmount" => "10000",
          "transactionDate" => Time.current.strftime("%m/%d/%Y"),
          "transactionAcountType" => "registration",
          "transactionResultCode" => "0",
          "transactionResultMessage" => "Approved",
          "orderNumber" => "user-1"
        }
      end

      before do
        sign_in user
        allow_any_instance_of(PaymentsController).to receive(:verify_payment_callback).and_return(true)

        mock_application = instance_double(Application)
        allow(mock_application).to receive(:update).and_return(true)
        allow_any_instance_of(PaymentsController).to receive(:current_application).and_return(mock_application)

        allow(ApplicationSetting).to receive(:get_current_app_year).and_return(Time.current.year)
      end

      context "when transaction_id already exists" do
        before do
          create(:payment, transaction_id: "existing_transaction_id")
          payment_params["transactionId"] = "existing_transaction_id"
        end

        it "does not create a new payment and redirects to all_payments_path" do
          post payment_receipt_path, params: payment_params
          expect(response).to redirect_to(all_payments_path)
        end
      end
    end
  end

  describe "DELETE /payments/:id/delete_manual_payment" do
    let!(:manual_payment) { create(:payment, transaction_type: "ManuallyEntered") }

    context "when admin user is not signed in" do
      it "redirects to admin sign in page" do
        post delete_manual_payment_path(manual_payment)
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end

    context "when admin user is signed in" do
      before do
        sign_in admin_user
      end

      it "destroys the payment" do
        expect {
          post delete_manual_payment_path(manual_payment)
        }.to change(Payment, :count).by(-1)
      end

      it "redirects to admin payments page" do
        post delete_manual_payment_path(manual_payment)
        expect(response).to redirect_to(admin_payments_url)
        expect(flash[:notice]).to eq("Payment was successfully deleted.")
      end
    end
  end
end
