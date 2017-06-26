class ServiceTypesController < ApplicationController
  def index
    @categories = ServiceType.all
  end

  def show
    @category = ServiceType.find(params[:id])
  end

  def new
    render :layout => 'touch'
  end

  def create

    redirect_to "/service_types" and return
  end

  def update

    redirect_to "/service_types/#{params[:id]}" and return
  end

  def edit

  end

  def destroy

  end
end
