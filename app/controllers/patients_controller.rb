class PatientsController < ApplicationController

  def create
    raise params.inspect
  end

  def confirm_demographics

    @settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env] rescue {}

    if @settings.blank?
      #No dde setting therefore create locally

    else
      #DDE available
      json_params = view_context.patient_json(params[:person],params["CURRENT AREA OR T/A"],true)

      @json = JSON.parse(json_params)
      #raise @json.inspect
      @settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env] # rescue {}

      if secure?
        url = "https://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/ajax_process_data"
      else
        url = "http://#{(@settings["dde_username"])}:#{(@settings["dde_password"])}@#{(@settings["dde_server"])}/ajax_process_data"
      end

      @results = RestClient.post(url, {"person" => json_params})

      render :layout => 'touch'
    end
  end

  def new

    settings = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env] rescue {}

    @show_middle_name = (settings["show_middle_name"] == true ? true : false) rescue false

    @show_maiden_name = (settings["show_maiden_name"] == true ? true : false) rescue false

    @show_birthyear = (settings["show_birthyear"] == true ? true : false) rescue false

    @show_birthmonth = (settings["show_birthmonth"] == true ? true : false) rescue false

    @show_birthdate = (settings["show_birthdate"] == true ? true : false) rescue false

    @show_age = (settings["show_age"] == true ? true : false) rescue false

    @show_region_of_origin = (settings["show_region_of_origin"] == true ? true : false) rescue false

    @show_district_of_origin = (settings["show_district_of_origin"] == true ? true : false) rescue false

    @show_t_a_of_origin = (settings["show_t_a_of_origin"] == true ? true : false) rescue false

    @show_home_village = (settings["show_home_village"] == true ? true : false) rescue false

    @show_current_region = (settings["show_current_region"] == true ? true : false) rescue false

    @show_current_district = (settings["show_current_district"] == true ? true : false) rescue false

    @show_current_t_a = (settings["show_current_t_a"] == true ? true : false) rescue false

    @show_current_village = (settings["show_current_village"] == true ? true : false) rescue false

    @show_current_landmark = (settings["show_current_landmark"] == true ? true : false) rescue false

    @show_cell_phone_number = (settings["show_cell_phone_number"] == true ? true : false) rescue false

    @show_office_phone_number = (settings["show_office_phone_number"] == true ? true : false) rescue false

    @show_home_phone_number = (settings["show_home_phone_number"] == true ? true : false) rescue false

    @show_occupation = (settings["show_occupation"] == true ? true : false) rescue false

    @show_nationality = (settings["show_nationality"] == true ? true : false) rescue false

    @occupations = ['','Driver','Housewife','Messenger','Business','Farmer','Salesperson','Teacher',
                    'Student','Security guard','Domestic worker', 'Police','Office worker',
                    'Preschool child','Mechanic','Prisoner','Craftsman','Healthcare Worker','Soldier'].sort.concat(["Other","Unknown"])

    @destination = request.referrer

    render :layout => 'touch'
  end

  def search
    @settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env] rescue {}

    @globals = YAML.load_file("#{Rails.root}/config/globals.yml")[Rails.env] rescue {}

    render :layout => 'touch'
  end

  def ajax_search
    pagesize = 3

    page = (params[:page] || 1)

    offset = ((page.to_i - 1) * pagesize)

    offset = 0 if offset < 0

    result = []

    filter = {}

    settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env] # rescue {}

    search_hash = {
        "names" => {
            "given_name" => (params["given_name"] rescue nil),
            "family_name" => (params["family_name"] rescue nil)
        },
        "gender" => params["gender"]
    }

    if !search_hash["names"]["given_name"].blank? and !search_hash["names"]["family_name"].blank? and !search_hash["gender"].blank? # and result.length < pagesize

      pagesize += pagesize - result.length
      if secure?
        url = "https://#{settings["dde_username"]}:#{settings["dde_password"]}@#{settings["dde_server"]}/ajax_process_data"
      else
        url = "http://#{settings["dde_username"]}:#{settings["dde_password"]}@#{settings["dde_server"]}/ajax_process_data"
      end
      remote = RestClient.post(url, {:person => search_hash, :page => page, :pagesize => pagesize}, {:accept => :json})

      json = JSON.parse(remote)

      json.each do |person|

        entry = JSON.parse(person)

        entry["application"] = "#{name_of_app}"
        entry["site_code"] = "#{facility_code}"

        entry["national_id"] = entry["_id"] if entry["national_id"].blank? and !entry["_id"].blank?

        filter[entry["national_id"]] = true

        entry["age"] = (((Date.today - entry["birthdate"].to_date).to_i / 365) rescue nil)

        entry.delete("created_at") rescue nil
        entry.delete("patient_assigned") rescue nil
        entry.delete("assigned_site") rescue nil
        entry["names"].delete("family_name_code") rescue nil
        entry["names"].delete("given_name_code") rescue nil
        entry.delete("_id") rescue nil
        entry.delete("updated_at") rescue nil
        entry.delete("old_identification_number") rescue nil
        entry.delete("type") rescue nil
        entry.delete("_rev") rescue nil

        result << entry

      end

    end

    # pagesize = ((pagesize) * 2) - result.length

    Person.all.joins(:names).where("given_name = ? AND family_name = ? AND gender = ?", params["given_name"], params["family_name"], params["gender"]).limit(pagesize).offset(offset ).each do |person|

      patient = person.patient # rescue nil

      national_id = (patient.patient_identifiers.find_by_identifier_type(PatientIdentifierType.find_by_name("National id").id).identifier rescue nil)

      next if filter[national_id]

      name = patient.person.names.last rescue nil

      address = patient.person.addresses.last rescue nil

      person = {
          "local" => true,
          "national_id" => national_id,
          "patient_id" => (patient.patient_id rescue nil),
          "age" => (((Date.today - patient.person.birthdate.to_date).to_i / 365) rescue nil),
          "names" =>
              {
                  "family_name" => (name.family_name rescue nil),
                  "given_name" => (name.given_name rescue nil),
                  "middle_name" => (name.middle_name rescue nil),
                  "maiden_name" => (name.family_name2 rescue nil)
              },
          "gender" => (patient.person.gender rescue nil),
          "person_attributes" => {
              "occupation" => (patient.person.person_attributes.find_by_person_attribute_type_id(PersonAttributeType.find_by_name("Occupation").id).value rescue nil),
              "cell_phone_number" => (patient.person.person_attributes.find_by_person_attribute_type_id(PersonAttributeType.find_by_name("Cell Phone Number").id).value rescue nil),
              "home_phone_number" => (patient.person.person_attributes.find_by_person_attribute_type_id(PersonAttributeType.find_by_name("Home Phone Number").id).value rescue nil),
              "office_phone_number" => (patient.person.person_attributes.find_by_person_attribute_type_id(PersonAttributeType.find_by_name("Office Phone Number").id).value rescue nil),
              "race" => (patient.person.person_attributes.find_by_person_attribute_type_id(PersonAttributeType.find_by_name("Race").id).value rescue nil),
              "country_of_residence" => (patient.person.person_attributes.find_by_person_attribute_type_id(PersonAttributeType.find_by_name("Country of Residence").id).value rescue nil),
              "citizenship" => (patient.person.person_attributes.find_by_person_attribute_type_id(PersonAttributeType.find_by_name("Citizenship").id).value rescue nil)
          },
          "birthdate" => (patient.person.birthdate rescue nil),
          "patient" => {
              "identifiers" => (patient.patient_identifiers.collect { |id| {id.type.name => id.identifier} if id.type.name.downcase != "national id" }.delete_if { |x| x.nil? } rescue [])
          },
          "birthdate_estimated" => ((patient.person.birthdate_estimated rescue 0).to_s.strip == '1' ? true : false),
          "addresses" => {
              "current_residence" => (address.address1 rescue nil),
              "current_village" => (address.city_village rescue nil),
              "current_ta" => (address.township_division rescue nil),
              "current_district" => (address.state_province rescue nil),
              "home_village" => (address.neighborhood_cell rescue nil),
              "home_ta" => (address.county_district rescue nil),
              "home_district" => (address.address2 rescue nil)
          }
      }

      person["application"] = "#{name_of_app}"
      person["site_code"] = "#{facility_code}"

      result << person

      # TODO: Need to find a way to limit in a better way the number of records returned without skipping any as some will never be seen with the current approach

      # break if result.length >= 7

    end if pagesize > 0 and result.length < 8

    render :text => result.to_json

  end

  def edit
    render :layout => 'touch'
  end

  def update

  end

  def show

    @patient = Patient.find(params[:id])

    range = Date.current.beginning_of_day..Date.current.end_of_day

    unpaid_orders = OrderEntry.select(:order_entry_id,:service_id,:quantity,:amount_paid,
                                      :full_price).where('patient_id = ? AND amount_paid < full_price', @patient.id)
    past_orders = OrderEntry.select(:order_entry_id,:service_id,:quantity, :full_price,:amount_paid,
                                    :order_date).where("patient_id = ? and order_date < ?",
                                                       @patient.id, Date.current.beginning_of_day)

    today_orders = OrderEntry.select(:order_entry_id,:service_id,:quantity, :full_price,:amount_paid,
                                    :order_date).where(patient_id: @patient.id,order_date: range)

    @unpaid_orders, @total, @amount_due = view_context.unpaid_records(unpaid_orders)
    @history = view_context.past_records(past_orders)
    @today_orders = view_context.past_records(today_orders)

  end

  def patient_by_id

    @settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env] rescue {}

    params[:id] = params[:id].strip.gsub(/\s/, "").gsub(/\-/, "") rescue params[:id]

    local_patient = Patient.search_locally(params[:id])

    #if dde settings don't exist
    if @settings.blank?
      if local_patient.blank? || local_patient["patient_id"].blank?
        #if dde doesn't exist and patient is not available locally
        redirect_to "/patients/patient_not_found/#{params[:id]}" and return
      end

    else
      #if dde exists
      @json = local_patient

      @results = []

      if !@json.blank?

        if secure?
          url = "https://#{@settings["dde_username"]}:#{@settings["dde_password"]}@#{@settings["dde_server"]}/ajax_process_data"
        else
          url = "http://#{@settings["dde_username"]}:#{@settings["dde_password"]}@#{@settings["dde_server"]}/ajax_process_data"
        end

        @results = RestClient.post(url, {:person => @json, :page => params[:page]}, {:accept => :json})

      end

      @dontstop = false

      #processing DDE result
      if JSON.parse(@results).length == 1

        result = JSON.parse(JSON.parse(@results)[0]) #Getting the first person here

        checked = DDE.compare_people(result, @json) # rescue false

        if checked

          result["patient_id"] = @json["patient_id"] if !@json["patient_id"].blank?

          @results = result.to_json

          person = JSON.parse(@results) #["person"]

          if secure?
            url = "https://#{@settings["dde_username"]}:#{@settings["dde_password"]}@#{@settings["dde_server"]}/process_confirmation"
          else
            url = "http://#{@settings["dde_username"]}:#{@settings["dde_password"]}@#{@settings["dde_server"]}/process_confirmation"
          end

          @results = RestClient.post(url, {:person => person, :target => "select"})

          @dontstop = true

        elsif !checked and @json["names"]["given_name"].blank? and @json["names"]["family_name"].blank? and @json["gender"].blank?

          # result["patient_id"] = @json["patient_id"] if !@json["patient_id"].blank?

          @results = result.to_json

          person = JSON.parse(@results) #["person"]

          if secure?
            url = "https://#{@settings["dde_username"]}:#{@settings["dde_password"]}@#{@settings["dde_server"]}/process_confirmation"
          else
            url = "http://#{@settings["dde_username"]}:#{@settings["dde_password"]}@#{@settings["dde_server"]}/process_confirmation"
          end

          @results = RestClient.post(url, {:person => person, :target => "select"})

          @dontstop = true

        else

          @results = []

          @results << result

          patient = PatientIdentifier.find_by_identifier(@json["national_id"]).patient rescue nil

          if !patient.nil?

            national_id = ((patient.patient_identifiers.find_by_identifier_type(PatientIdentifierType.find_by_name("National id").id).identifier rescue nil) || params[:id])

            verifier = local_patient.to_json

            checked = DDE.compare_people(result, verifier) # rescue false

            if checked

              result["patient_id"] = @json["patient_id"] if !@json["patient_id"].blank?

              @results = result.to_json

              person = JSON.parse(@results) #["person"]

              if secure?
                url = "https://#{@settings["dde_username"]}:#{@settings["dde_password"]}@#{@settings["dde_server"]}/process_confirmation"
              else
                url = "http://#{@settings["dde_username"]}:#{@settings["dde_password"]}@#{@settings["dde_server"]}/process_confirmation"
              end

              @results = RestClient.post(url, {:person => person, :target => "select"})

              @dontstop = true

            end

          else

            @dontstop = true

          end

        end

      elsif JSON.parse(@results).length == 0

        patient = PatientIdentifier.find_by_identifier(@json["national_id"]).patient rescue nil

        if patient.blank?
          redirect_to "/patient_not_found/#{params[:id]}" and return
        else
          @results = []
          @results << local_patient.to_json
          @dontstop = true
        end

      end

    end

    render :layout => 'touch'
  end

  def process_result
    json = JSON.parse(params["person"]) rescue {}

    if (json["patient"]["identifiers"].class.to_s.downcase == "hash" rescue false)

      tmp = json["patient"]["identifiers"]

      json["patient"]["identifiers"] = []

      (tmp || []).each do |key, value|

        json["patient"]["identifiers"] << {key => value}

      end

    end

    patient_id = DDE.search_and_or_create(json.to_json) # rescue nil

    # raise patient_id.inspect

    json = JSON.parse(params["person"]) rescue {}

    patient = Patient.find(patient_id) rescue nil

    #if print barcode
    print_and_redirect("/patients/print_national_id?patient_id=#{patient_id}", "/patients/#{patient.id}") and return if !patient.blank? and (json["print_barcode"] rescue false)


    redirect_to "/patients/#{patient.id}" and return if !patient.blank?

    flash["error"] = "Sorry! Something went wrong. Failed to process properly!"

    redirect_to "/" and return

  end

  def ajax_process_data

    settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env] rescue {}

    person = params[:person] rescue {}

    result = []

    if !person.blank?
      if secure?
        url = "https://#{settings["dde_username"]}:#{settings["dde_password"]}@#{settings["dde_server"]}/ajax_process_data"
      else
        url = "http://#{settings["dde_username"]}:#{settings["dde_password"]}@#{settings["dde_server"]}/ajax_process_data"
      end

      results = RestClient.post(url, {:person => person, :page => params[:page]}, {:accept => :json})

      result = JSON.parse(results)

      json = JSON.parse(params[:person]) rescue {}

      patient = PatientIdentifier.find_by_identifier(json["national_id"]).patient rescue nil

      if !patient.nil?

        name = patient.person.names.last rescue nil

        address = patient.person.addresses.last rescue nil

        result << {
            "_id" => json["national_id"],
            "patient_id" => (patient.patient_id rescue nil),
            "local" => true,
            "names" =>
                {
                    "family_name" => (name.family_name rescue nil),
                    "given_name" => (name.given_name rescue nil),
                    "middle_name" => (name.middle_name rescue nil),
                    "maiden_name" => (name.family_name2 rescue nil)
                },
            "gender" => (patient.person.gender rescue nil),
            "person_attributes" => {
                "occupation" => (patient.person.person_attributes.find_by_person_attribute_type_id(PersonAttributeType.find_by_name("Occupation").id).value rescue nil),
                "cell_phone_number" => (patient.person.person_attributes.find_by_person_attribute_type_id(PersonAttributeType.find_by_name("Cell Phone Number").id).value rescue nil),
                "home_phone_number" => (patient.person.person_attributes.find_by_person_attribute_type_id(PersonAttributeType.find_by_name("Home Phone Number").id).value rescue nil),
                "office_phone_number" => (patient.person.person_attributes.find_by_person_attribute_type_id(PersonAttributeType.find_by_name("Office Phone Number").id).value rescue nil),
                "race" => (patient.person.person_attributes.find_by_person_attribute_type_id(PersonAttributeType.find_by_name("Race").id).value rescue nil),
                "country_of_residence" => (patient.person.person_attributes.find_by_person_attribute_type_id(PersonAttributeType.find_by_name("Country of Residence").id).value rescue nil),
                "citizenship" => (patient.person.person_attributes.find_by_person_attribute_type_id(PersonAttributeType.find_by_name("Citizenship").id).value rescue nil)
            },
            "birthdate" => (patient.person.birthdate rescue nil),
            "patient" => {
                "identifiers" => (patient.patient_identifiers.collect { |id| {id.type.name => id.identifier} if id.type.name.downcase != "national id" }.delete_if { |x| x.nil? } rescue [])
            },
            "birthdate_estimated" => ((patient.person.birthdate_estimated rescue 0).to_s.strip == '1' ? true : false),
            "addresses" => {
                "current_residence" => (address.address1 rescue nil),
                "current_village" => (address.city_village rescue nil),
                "current_ta" => (address.township_division rescue nil),
                "current_district" => (address.state_province rescue nil),
                "home_village" => (address.neighborhood_cell rescue nil),
                "home_ta" => (address.county_district rescue nil),
                "home_district" => (address.address2 rescue nil)
            }
        }.to_json

      end

      result = result.to_json

    end

    render :text => result
  end

  def process_confirmation

    @json = params[:person] rescue {}

    @results = []

    settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env] rescue {}

    target = params[:target]

    target = "update" if target.blank?

    if !@json.blank?
      if secure?
        url = "https://#{settings["dde_username"]}:#{settings["dde_password"]}@#{settings["dde_server"]}/process_confirmation"
      else
        url = "http://#{settings["dde_username"]}:#{settings["dde_password"]}@#{settings["dde_server"]}/process_confirmation"
      end
      @results = RestClient.post(url, {:person => @json, :target => target}, {:accept => :json})
    end

    render :text => @results
  end

  def patient_not_found
    @id = params[:id]

    redirect_to "/" and return if !params[:create].blank? and params[:create] == "false"
  end

  def print_national_id
    @patient = Patient.find(params[:patient_id])
    print_string = Misc.patient_national_id_label(@patient)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{params[:patient_id]}#{rand(10000)}.lbl", :disposition => "inline")
  end

  def district
    region_id = Region.find_by_name("#{params[:filter_value]}").id
    region_conditions = ["name LIKE (?) AND region_id = ? ", "#{params[:search_string]}%", region_id]

    districts = District.all.where( region_conditions).order('name')
    districts = districts.map do |d|
      "<li value=\"#{d.name}\">#{d.name}</li>"
    end
    render :text => districts.join('') + "<li value='Other'>Other</li>" and return
  end

  # List traditional authority containing the string given in params[:value]
  def traditional_authority
    district_id = District.find_by_name("#{params[:filter_value]}").id
    traditional_authority_conditions = ["name LIKE (?) AND district_id = ?", "%#{params[:search_string]}%", district_id]

    traditional_authorities = TraditionalAuthority.all.where(traditional_authority_conditions).order('name')
    traditional_authorities = traditional_authorities.map do |t_a|
      "<li value=\"#{t_a.name}\">#{t_a.name}</li>"
    end
    render :text => traditional_authorities.join('') + "<li value='Other'>Other</li>" and return
  end

  # Villages containing the string given in params[:value]
  def village
    traditional_authority_id = TraditionalAuthority.find_by_name("#{params[:filter_value]}").id
    village_conditions = ["name LIKE (?) AND traditional_authority_id = ?", "%#{params[:search_string]}%", traditional_authority_id]

    villages = Village.all.where(village_conditions).order('name')
    villages = villages.map do |v|
      "<li value=\"#{v.name}\">#{v.name}</li>"
    end
    render :text => villages.join('') + "<li value='Other'>Other</li>" and return
  end

  # Landmark containing the string given in params[:value]
  def landmark

    landmarks = ["", "Market", "School", "Police", "Church", "Borehole", "Graveyard"]
    landmarks = landmarks.map do |v|
      "<li value='#{v}'>#{v}</li>"
    end
    render :text => landmarks.join('') + "<li value='Other'>Other</li>" and return
  end

  # Countries containing the string given in params[:value]
  def country
    country_conditions = ["name LIKE (?)", "%#{params[:search_string]}%"]

    countries = Country.all.where(country_conditions).order('weight')
    countries = countries.map do |v|
      "<li value=\"#{v.name}\">#{v.name}</li>"
    end
    render :text => countries.join('') + "<li value='Other'>Other</li>" and return
  end

  # Nationalities containing the string given in params[:value]
  def nationality
    nationalty_conditions = ["name LIKE (?)", "%#{params[:search_string]}%"]

    nationalities = Nationality.all.where(nationalty_conditions).order('weight')
    nationalities = nationalities.map do |v|
      "<li value=\"#{v.name}\">#{v.name}</li>"
    end
    render :text => nationalities.join('') + "<li value='Other'>Other</li>" and return
  end

  def family_names
    searchname("family_name", params[:search_string])
  end

  def given_names
    searchname("given_name", params[:search_string])
  end

  def family_name2
    searchname("family_name2", params[:search_string])
  end

  def middle_name
    searchname("middle_name", params[:search_string])
  end

  def searchname(field_name, search_string)
    @names = PersonNameCode.find_most_common(field_name, search_string).collect{|person_name| person_name.send(field_name)} # rescue []
    render :text => "<li>" + @names.map{|n| n } .join("</li><li>") + "</li>"
  end

  def secure?
    @settings = YAML.load_file("#{Rails.root}/config/dde_connection.yml")[Rails.env]
    secure = @settings["secure_connection"] rescue false
  end
end
