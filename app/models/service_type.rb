class ServiceType < ActiveRecord::Base
  default_scope {-> { where "#{self.table_name}.retired = false" }}
  has_many :services
  has_many :service_panels

  def number_of_services
  self.services.select("count(service_id) as count").first.count
  end
end
