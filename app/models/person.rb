class Person < ActiveRecord::Base
  establish_connection Registration
  self.table_name = "person"
  self.primary_key = "person_id"
  include Openmrs

  has_one :patient,-> {where voided: 0}, :foreign_key => :patient_id, :dependent => :destroy
  has_many :names, :class_name => 'PersonName', :foreign_key => :person_id, :dependent => :destroy
  has_many :addresses, :class_name => 'PersonAddress', :foreign_key => :person_id, :dependent => :destroy
  has_many :person_attributes, :class_name => 'PersonAttribute', :foreign_key => :person_id

  def display_age
    age_in_days = (Date.current - self.birthdate).to_i

    if age_in_days < 31
      return age_in_days.to_s + " days"
    elsif age_in_days < 548
      years = (Date.today.year - self.birthdate.year)
      months = (Date.today.month - self.birthdate.month)
      return ((years * 12) + months).to_s + " months"
    else
      return (age_in_days / 365).to_s + " years"
    end
  end

  def is_child?
    age_in_days = (Date.current - self.birthdate).to_i

    if age_in_days < 4380
      return true
    else
      return false
    end
  end
  def after_void(reason = nil)
    self.patient.void(reason) rescue nil
    self.names.each{|row| row.void(reason) }
    self.addresses.each{|row| row.void(reason) }

    #self.person_attributes.each{|row| row.void(reason) }
  end
end