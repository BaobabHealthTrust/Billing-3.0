class ServicesController < ApplicationController
  def index
    @services = Service.all
  end

  def show
    @service = Service.find(params[:id])
  end

  def update

  end

  def edit

  end

  def destroy

  end

  def suggestions
    type = ServiceType.find_by_name(params[:category])
    services = Service.select(:name).where('service_type_id = ? and name like (?)',
                                           type.id, "%#{params[:search_string]}%" ).map do |v|
                                            "<li value=\"#{v.name}\">#{v.name}</li>"
    end

    render :text => services.join('') and return
  end
end
