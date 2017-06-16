class Service < ActiveRecord::Base
  default_scope {-> { where "#{self.table_name}.voided = false" }}
  has_many :service_prices,-> { where "#{self.table_name}.voided = false" }
  has_many :service_price_histories
  belongs_to :service_type,-> { where "#{self.table_name}.retired = false" }
end
