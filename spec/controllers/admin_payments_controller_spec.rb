require 'rails_helper'

RSpec.describe Admin::PaymentsController, type: :controller do
  let(:admin_user) { create(:admin_user) }
  let!(:payment) { create(:payment, :manual) }

  describe 'DELETE #destroy' do
    context 'when admin user is authenticated' do
      before { sign_in admin_user }

      it 'deletes a manually entered payment' do
        expect {
          delete :destroy, params: { id: payment.id }
        }.to change(Payment, :count).by(-1)
      end

      it 'redirects to admin payments with success notice' do
        delete :destroy, params: { id: payment.id }
        expect(response).to redirect_to(admin_payments_path)
        expect(flash[:notice]).to eq('Payment was successfully deleted.')
      end

      it 'does not delete non-manual payments' do
        gateway_payment = create(:payment, transaction_type: 'Credit')
        expect {
          delete :destroy, params: { id: gateway_payment.id }
        }.not_to change(Payment, :count)
        expect(flash[:alert]).to eq('Only manually entered payments can be deleted.')
      end
    end

    context 'when not authenticated' do
      it 'redirects to admin sign in' do
        delete :destroy, params: { id: payment.id }
        expect(response).to redirect_to(new_admin_user_session_path)
      end
    end
  end
end
