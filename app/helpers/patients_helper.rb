module PatientsHelper
  def patient_json(params,current_ta='Unknown',print_barcode=false)
   json = {
        'national_id' => nil,
        'application' => "#{name_of_app}",
        'site_code' => "#{facility_code}",
        'return_path' => '"http://#{request.host_with_port}/process_result',
        'print_barcode' => print_barcode,
        'names' =>
            {
                'family_name' => params[:names][:family_name],
                'given_name' => params[:names][:given_name],
                'middle_name' => params[:names][:middle_name],
                'maiden_name' => (params[:names][:family_name2].blank? ? nil : params[:names][:family_name2])
            },
        'gender' => (params[:gender] == 'F' ? 'Female' : 'Male'),
        'person_attributes' => {
            'country_of_residence' => nil,
            'citizenship' => params["citizenship"],
            'occupation' => params["occupation"],
            'home_phone_number' => params["home_phone_number"],
            'cell_phone_number' => params["cell_phone_number"],
            'office_phone_number' => params["office_phone_number"],
            'race' => params["race"]
        },
        'birthdate' => nil,
        'patient' => {
            'identifiers' => []
        },
        'birthdate_estimated' => nil,
        'addresses' => {
            'current_residence' => params["addresses"]["address1"],
            'current_village' => params["addresses"]["city_village"],
            'current_ta' => current_ta,
            'current_district' => params["addresses"]["state_province"],
            'home_village' => params["addresses"]["neighborhood_cell"],
            'home_ta' => params["addresses"]["county_district"],
            'home_district' => params["addresses"]["address2"],
            'landmark' => params["addresses"]["address1"]
        }
    }.to_json
  end

  def past_records(entries)
    records = {}
    (entries || []).each do |entry|
      status = entry.status
      date = entry.order_date.strftime("%d %b %Y")

      records[date] = {"summary" => {},"details" => []} if records[date].blank?
      records[date]["details"] << {service: entry.description, quantity: entry.quantity,
                                                         price: entry.full_price, id: entry.id,
                                                         status: status[:bill_status]}

      (records[date]["summary"]["bill"].blank? ? records[date]["summary"]["bill"] = entry.full_price : records[date]["summary"]["bill"]+= entry.full_price)
      (records[date]["summary"]["paid"].blank? ? records[date]["summary"]["paid"] = status[:amount] : records[date]["summary"]["paid"]+= status[:amount])

    end

    return records
  end

  def unpaid_records(orders)

    @unpaid_orders = {}
    @total = 0
    @amount_due = 0

    (orders || []).each do |record|
      if @unpaid_orders[record.service_id].blank?
        @unpaid_orders[record.service_id] = {service_name: record.description, amount: record.full_price ,
                                      quantity: record.quantity, id: [record.order_entry_id] }
      else
        @unpaid_orders[record.service_id][:amount] += record.full_price
        @unpaid_orders[record.service_id][:quantity] += record.quantity
        @unpaid_orders[record.service_id][:id] << record.order_entry_id
      end
      @total += record.full_price
      @amount_due += (record.full_price - record.amount_paid)
    end

    return [@unpaid_orders, @total, @amount_due]
  end
end
