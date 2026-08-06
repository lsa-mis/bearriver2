module Admin
  class PartnerRegistrationsController < BaseController
    before_action :set_partner_registration, only: %i[show edit update destroy]

    def index
      @partner_registrations = PartnerRegistration.order(:id)
    end

    def show
    end

    def new
      @partner_registration = PartnerRegistration.new
    end

    def edit
    end

    def create
      @partner_registration = PartnerRegistration.new(partner_registration_params)
      if @partner_registration.save
        redirect_to admin_partner_registration_path(@partner_registration), notice: 'Partner registration was successfully created.'
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @partner_registration.update(partner_registration_params)
        redirect_to admin_partner_registration_path(@partner_registration), notice: 'Partner registration was successfully updated.'
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @partner_registration.destroy
      redirect_to admin_partner_registrations_path, notice: 'Partner registration was successfully deleted.'
    end

    private

    def set_partner_registration
      @partner_registration = PartnerRegistration.find(params[:id])
    end

    def partner_registration_params
      params.require(:partner_registration).permit(:description, :cost, :active)
    end
  end
end
