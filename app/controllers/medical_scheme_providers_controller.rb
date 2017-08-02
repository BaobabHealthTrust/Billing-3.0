class MedicalSchemeProvidersController < ApplicationController
  def index
    @insurers = MedicalSchemeProvider.all
  end
  def show
    @insurer = MedicalSchemeProvider.find(params[:id])
  end
  def new
    render :layout => 'touch'
  end
  def create

    @new_insurer = MedicalSchemeProvider.create(medical_scheme_provider_params)
    redirect_to @new_insurer
  end
  def edit

  end
  def update

  end
  def destroy

  end

  private

  def medical_scheme_provider_params
    params.require(:medical_scheme_provider).permit(:company_name, :company_address,:phone_number_1,
                                                    :phone_number_2,:email_address,:creator)
  end
end
