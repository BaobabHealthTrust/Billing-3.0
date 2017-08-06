class LocationsController < ApplicationController
  def index
    render :layout => 'touch'
  end

  def show
    print_and_redirect("/locations/print_label?location=#{params[:location]}", "/")
  end

  def new
    render :layout => 'touch'
  end

  def create

    if Location.find_by_name(params[:location]).blank?
      location = Location.new
      location.name = params[:location]
      location.creator  = current_user.id.to_s
      location.date_created  = Time.current.strftime("%Y-%m-%d %H:%M:%S")
      location.save rescue (result = false)

      location_tag_map = LocationTagMap.new
      location_tag_map.location_id = location.id
      location_tag_map.location_tag_id = LocationTag.find_by_name("Workstation location").id
      result = location_tag_map.save

      if result == true then
        flash[:success] = "location #{params[:location]} added successfully"
      else
        flash[:error] = "location #{params[:location]} addition failed"
      end
    else
      location_id = Location.find_by_name(params[:location]).id
      location_tag_id = LocationTag.find_by_name("Workstation location").id
      location_tag_map = LocationTagMap.where(location_id: location_id, location_tag_id: location_tag_id).first_or_initialize

      result = location_tag_map.save

      if result == true then
        flash[:notice] = "location #{params[:location]} added successfully"
      else
        flash[:notice] = "<span style='color:red; display:block; background-color:#DDDDDD;'>location #{params[:location]} addition failed</span>"
      end
    end

    redirect_to "/" and return

  end

  def update

  end

  def destroy

  end

  def search

    workstation_id = LocationTag.select(:location_tag_id).find_by_name("workstation location")
    locations = workstation_id.location_tag_map.collect{|x| x.location_id}
    names = Location.select(:name, :location_id).where("name LIKE '%#{params[:search_string]}%'
                                                        AND location_id in (?)", locations).map do |v|
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
