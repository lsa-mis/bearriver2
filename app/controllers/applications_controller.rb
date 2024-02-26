class ApplicationsController < ApplicationController

  before_action :authenticate_user!, except: [:send_balance_due]
  before_action :authenticate_admin_user!, only: [:send_balance_due]
  before_action :set_application, only: [:show, :edit, :update, :destroy]
  before_action :get_lodgings
  before_action :get_partner_registrations
  # before_action :contest_is_closed?, only: [:new]

  # GET /applications
  # GET /applications.json
  def index
    redirect_to root_url
  end

  # GET /applications/1
  # GET /applications/1.json
  def show
    cost_lodging = Lodging.find_by(description: @application.lodging_selection).cost.to_f
    cost_partner = @application.partner_registration.cost.to_f
    @total_cost = cost_lodging + cost_partner
  end

  # GET /applications/new
  def new
    redirect_to root_path if current_user.current_conf_application.present?
    @application = Application.new
  end

  # GET /applications/1/edit
  def edit
    redirect_to root_path unless @application.offer_status.blank?
  end

  # POST /applications
  # POST /applications.json
  def create
    @application = Application.new(application_params)
    @application.email = current_user.email
    @application.user = current_user
    respond_to do |format|
      if @application.save
        if (["special", "scholarship"] & current_user.payments.current_conference_payments.pluck(:account_type)).any?
            @application.update(offer_status: 'registration_accepted')
        end
        AppConfirmationMailer.with(app: current_user.current_conf_application).application_submitted.deliver_now
        format.html { redirect_to @application, notice: 'Here are your Application Details.' }
        format.json { render :show, status: :created, location: @application }
      else
        format.html { render :new }
        format.json { render json: @application.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /applications/1
  # PATCH/PUT /applications/1.json
  def update
    respond_to do |format|
      if @application.update(application_params)
        if params[:update_subscription] == 'update'
          format.html { redirect_to all_payments_path, notice: 'Subscription was updated.' }
          format.json { render :show, status: :ok, location: all_payments_path }
        else
          format.html { redirect_to @application, notice: 'Application was successfully updated.' }
          format.json { render :show, status: :ok, location: @application }
        end
      else
        format.html { render :edit }
        format.json { render json: @application.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /applications/1
  # DELETE /applications/1.json
  def destroy
    @application.destroy
    respond_to do |format|
      format.html { redirect_to root_url, notice: 'Application was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def subscription 
    @application = Application.active_conference_applications.find_by(user_id: current_user)
  end

  def send_balance_due
    message_count = 0
    @applications_accepted = Application.application_accepted
    @applications_accepted.each do |application|
      if application.balance_due > 0
        BalanceDueMailer.with(app: application).outstanding_balance.deliver_now
        message_count += 1
      end
    end
    flash[:alert] = "#{message_count} balance due messages sent."
    redirect_to admin_root_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      @application = Application.find(params[:id])
      redirect_to root_url, alert: 'Not Authorized!' unless @application.user === current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def application_params
      params.require(:application).permit(:first_name, :last_name, :gender, :birth_year, :street, :street2, :city, :state, :zip, :country, :phone, :email, :email_confirmation, :workshop_selection1, :workshop_selection2, :workshop_selection3, :lodging_selection, :partner_registration_selection, :partner_registration_id, :partner_first_name, :partner_last_name, :how_did_you_hear, :accessibility_requirements, :special_lodging_request, :food_restrictions, :user_id, :subscription)
    end

end
