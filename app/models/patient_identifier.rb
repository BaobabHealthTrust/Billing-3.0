class PatientIdentifier < ActiveRecord::Base
  establish_connection Registration
  self.table_name= "patient_identifier"
  include Openmrs

  belongs_to :type,-> { where "retired = 0" }, :class_name => "PatientIdentifierType", :foreign_key => :identifier_type
  belongs_to :patient, -> { where "voided = 0" }

  before_create :before_create
  before_update :before_save
  before_save :before_save

  def self.calculate_checkdigit(number)
    # This is Luhn's algorithm for checksums
    # http://en.wikipedia.org/wiki/Luhn_algorithm
    # Same algorithm used by PIH (except they allow characters)
    number = number.to_s
    number = number.split(//).collect { |digit| digit.to_i }
    parity = number.length % 2

    sum = 0
    number.each_with_index do |digit,index|
      luhn_transform = ((index + 1) % 2 == parity ? (digit * 2) : digit)
      luhn_transform = luhn_transform - 9 if luhn_transform > 9
      sum += luhn_transform
    end

    checkdigit = (sum * 9 )%10
    return checkdigit

  end

  def self.identifier(patient_id, patient_identifier_type_id)
    patient_identifier = self.first.select("identifier").where("patient_id = ? and identifier_type = ?",patient_id, patient_identifier_type_id)

    return patient_identifier
  end

  def after_save
    create_from_dde_server = CoreService.get_global_property_value('create.from.dde.server').to_s == "true" rescue false

    if !create_from_dde_server
      if self.identifier_type == PatientIdentifierType.find_by_name("National ID").id
        person = self.patient.person
        patient_bin = PatientService.get_patient(person)
        date_created = person.date_created.strftime('%Y-%m-%d %H:%M:%S') rescue Time.now().strftime('%Y-%m-%d %H:%M:%S')
        first_name = patient_bin.name.split(" ")[0] rescue nil
        last_name = patient_bin.name.split(" ")[1] rescue nil
        birthdate_estimated = person.birthdate_estimated

        ActiveRecord::Base.connection.execute <<EOF
INSERT INTO openmrs_demographx.patient (patient_id,gender,birthdate,birthdate_estimated,creator,date_created,date_changed)
VALUES(#{patient_bin.patient_id},"#{patient_bin.sex}","#{person.birthdate}",#{birthdate_estimated},#{person.creator},'#{date_created}','#{date_created}');
EOF

        ActiveRecord::Base.connection.execute <<EOF
INSERT INTO openmrs_demographx.patient_name (patient_id,given_name,family_name,creator,date_created,date_changed)
VALUES(#{patient_bin.patient_id},"#{first_name}","#{last_name}",#{person.creator},'#{date_created}','#{date_created}');
EOF

        ActiveRecord::Base.connection.execute <<EOF
INSERT INTO openmrs_demographx.patient_identifier (patient_id,identifier,identifier_type,creator,date_created)
VALUES(#{patient_bin.patient_id},"#{patient_bin.national_id}",1,#{person.creator},'#{date_created}');
EOF
      end rescue nil
    end
  end

  def before_save
    self.creator = 1 if self.creator.blank?
    self.date_created = Time.now if self.date_created.blank?
  end

end
