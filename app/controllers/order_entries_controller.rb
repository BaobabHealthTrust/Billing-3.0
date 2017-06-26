class OrderEntriesController < ApplicationController
  def new
    @categories = ServiceType.select(:name,:service_type_id).collect{|x|x.name}.sort
    #@categories = ServiceType.select(:name,:service_type_id).collect{|x|[x.name, x.services.count]}.sort
    render :layout => 'touch'
  end

  def create

    patient = Patient.find(params[:order_entry][:patient_id])
    (params[:order_entry][:categories] || []).each do |category|
      if category.downcase == "consultation"
        if patient.person.is_child?
          OrderEntry.create(:patient_id => patient.id,:order_date => DateTime.current, :quantity => 1,
                            :service_offered => 'Consultation (peadiatric)',:location =>params[:order_entry][:location],
                            :service_point =>params[:order_entry][:location_name],:cashier => params[:creator])
        else
          OrderEntry.create(:patient_id => patient.id,:order_date => DateTime.current, :quantity => 1,
                            :service_offered => 'Consultation', :location =>params[:order_entry][:location],
                            :service_point =>params[:order_entry][:location_name], :cashier => params[:creator])
        end
      else

        (params[:order_entry][category.downcase.gsub(' ','_')] || []).each do |item|
          OrderEntry.create(:patient_id => patient.id,:order_date => DateTime.current, :quantity => 1,
                            :service_offered => item, :location =>params[:order_entry][:location],
                            :service_point =>params[:order_entry][:location_name],
                            :cashier => params[:creator])
        end

        next if params[:order_entry][:panels].blank?
        (params[:order_entry][:panels][category.downcase.gsub(' ','_')] || []).each do |panel|
          service_panel = ServicePanel.find_by_name(panel)
          next if service_panel.blank?
          (service_panel.service_panel_details ||[]).each do |item|
            OrderEntry.create(:patient_id => patient.id,:order_date => DateTime.current, :quantity => item.quantity,
                              :service_id => item.service_id, :location =>params[:order_entry][:location],
                              :service_point =>params[:order_entry][:location_name],
                              :cashier => params[:creator])
          end
        end
      end
    end

    redirect_to patient
  end

  def edit
    render :layout => 'touch'
  end

  def update

  end

  def destroy
    entry = OrderEntry.where(order_entry_id: params[:id]).first
    entry.void(params[:reason])
  end
end
