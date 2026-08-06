module Admin
  class WorkshopsController < BaseController
    before_action :set_workshop, only: %i[show edit update destroy]

    def index
      @workshops = Workshop.order(:id)
      @workshops = @workshops.where(last_name: params[:last_name]) if params[:last_name].present?
      @workshops = @workshops.where(active: params[:active] == 'true') if params[:active].present?
    end

    def show
    end

    def new
      @workshop = Workshop.new
    end

    def edit
    end

    def create
      @workshop = Workshop.new(workshop_params)
      if @workshop.save
        redirect_to admin_workshop_path(@workshop), notice: 'Workshop was successfully created.'
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @workshop.update(workshop_params)
        redirect_to admin_workshop_path(@workshop), notice: 'Workshop was successfully updated.'
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @workshop.destroy
      redirect_to admin_workshops_path, notice: 'Workshop was successfully deleted.'
    end

    private

    def set_workshop
      @workshop = Workshop.find(params[:id])
    end

    def workshop_params
      params.require(:workshop).permit(:instructor, :last_name, :first_name, :active)
    end
  end
end
