module Admin
  class LodgingsController < BaseController
    before_action :set_lodging, only: %i[show edit update destroy]

    def index
      @lodgings = Lodging.order(:id)
    end

    def show
    end

    def new
      @lodging = Lodging.new
    end

    def edit
    end

    def create
      @lodging = Lodging.new(lodging_params)
      if @lodging.save
        redirect_to admin_lodging_path(@lodging), notice: 'Lodging was successfully created.'
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @lodging.update(lodging_params)
        redirect_to admin_lodging_path(@lodging), notice: 'Lodging was successfully updated.'
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @lodging.destroy
      redirect_to admin_lodgings_path, notice: 'Lodging was successfully deleted.'
    end

    private

    def set_lodging
      @lodging = Lodging.find(params[:id])
    end

    def lodging_params
      params.require(:lodging).permit(:plan, :description, :cost)
    end
  end
end
