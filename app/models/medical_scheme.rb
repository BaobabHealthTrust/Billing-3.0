class MedicalScheme < ActiveRecord::Base
  belongs_to :medical_scheme_provider, :foreign_key => :medical_scheme_provider
  has_one :user, :foreign_key => :creator
end
