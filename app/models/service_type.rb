class ServiceType < ActiveRecord::Base
  default_scope {-> { where "#{self.table_name}.retired = false" }}
  has_many :services
end
