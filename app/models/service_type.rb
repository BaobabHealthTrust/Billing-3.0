class ServiceType < ActiveRecord::Base
  default_scope {-> { where "retired = false" }}
  has_many :services, -> { where "voided = 0" }
end
