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
                            :service_offered => 'Consultation (peadiatric)',
                            :service_point =>params[:order_entry][:location],
                            :cashier => params[:creator] )
        else
          OrderEntry.create(:patient_id => patient.id,:order_date => DateTime.current, :quantity => 1,
                            :service_offered => 'Consultation', :service_point =>params[:order_entry][:location],
                            :cashier => params[:creator])
        end
      else
        sub_category =
        (params[:order_entry][category.downcase.gsub(' ','_')] || []).each do |item|
          OrderEntry.create(:patient_id => patient.id,:order_date => DateTime.current, :quantity => 1,
                            :service_offered => item, :service_point =>params[:order_entry][:location],
                            :cashier => params[:creator])
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
