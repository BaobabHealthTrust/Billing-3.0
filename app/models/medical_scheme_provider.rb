class MedicalSchemeProvider < ActiveRecord::Base
  has_many :medical_schemes
  has_one :user, :foreign_key => :creator
end
