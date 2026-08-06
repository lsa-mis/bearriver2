module Admin
  class GendersController < BaseController
    before_action :set_gender, only: %i[show edit update destroy]

    def index
      @genders = Gender.order(:id)
    end

    def show
    end

    def new
      @gender = Gender.new
    end

    def edit
    end

    def create
      @gender = Gender.new(gender_params)
      if @gender.save
        redirect_to admin_gender_path(@gender), notice: 'Gender was successfully created.'
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @gender.update(gender_params)
        redirect_to admin_gender_path(@gender), notice: 'Gender was successfully updated.'
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @gender.destroy
      redirect_to admin_genders_path, notice: 'Gender was successfully deleted.'
    end

    private

    def set_gender
      @gender = Gender.find(params[:id])
    end

    def gender_params
      params.require(:gender).permit(:name, :description)
    end
  end
end
