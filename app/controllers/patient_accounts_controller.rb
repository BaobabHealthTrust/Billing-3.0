class PatientAccountsController < ApplicationController
  def index

  end

  def new
    @providers = MedicalSchemeProvider.all.collect{|x| x.company_name}
    render :layout => 'touch'
  end

  def create

  end

  def edit

  end

  def update

  end

  def destroy

  end
end
