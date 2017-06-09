class ServiceType < ActiveRecord::Base
  has_many :services, -> { where "voided = 0" }
  default_scope {-> { where "retired = false" }}
end
