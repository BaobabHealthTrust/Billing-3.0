class LocationsController < ApplicationController
  def index
    render :layout => 'touch'
  end

  def show
    print_and_redirect("/locations/print_label?location=#{params[:location]}", "/")
  end

  def new

  end

  def create

  end

  def update

  end

  def destroy

  end

  def search

    names = Location.select(:name, :location_id).where("name LIKE '%#{params[:search_string]}%'").map do |v|
      "<li value=\"#{v.location_id}\">#{v.name}</li>"
    end

    render :text => names.join('')

  end

  def print_label

    print_string = Misc.print_location(params[:location])
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false,
              :filename=>"#{(0..8).map { (65 + rand(26)).chr }.join}.lbl", :disposition => "inline")
  end

end
