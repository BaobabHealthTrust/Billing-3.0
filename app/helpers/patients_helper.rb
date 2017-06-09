module PatientsHelper
  def patient_json(params,current_ta='Unknown',print_barcode=false)
   json = {
        "national_id" => nil,
        "application" => "#{name_of_app}",
        "site_code" => "#{facility_code}",
        "return_path" => "http://#{request.host_with_port}/process_result",
        "print_barcode" => print_barcode,
        "names" =>
            {
                "family_name" => params[:names][:family_name],
                "given_name" => params[:names][:given_name],
                "middle_name" => params[:names][:middle_name],
                "maiden_name" => (params[:names][:family_name2].blank? ? nil : params[:names][:family_name2])
            },
        "gender" => (params[:gender] == "F" ? "Female" : "Male"),
        "person_attributes" => {
            "country_of_residence" => nil,
            "citizenship" => params["citizenship"],
            "occupation" => params["occupation"],
            "home_phone_number" => params["home_phone_number"],
            "cell_phone_number" => params["cell_phone_number"],
            "office_phone_number" => params["office_phone_number"],
            "race" => params["race"]
        },
        "birthdate" => nil,
        "patient" => {
            "identifiers" => []
        },
        "birthdate_estimated" => nil,
        "addresses" => {
            "current_residence" => params["addresses"]["address1"],
            "current_village" => params["addresses"]["city_village"],
            "current_ta" => current_ta,
            "current_district" => params["addresses"]["state_province"],
            "home_village" => params["addresses"]["neighborhood_cell"],
            "home_ta" => params["addresses"]["county_district"],
            "home_district" => params["addresses"]["address2"],
            "landmark" => params["addresses"]["address1"]
        }
    }.to_json
  end
end
