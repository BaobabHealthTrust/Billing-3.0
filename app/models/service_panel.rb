class ServicePanel < ActiveRecord::Base
  has_many :service_panel_details
  belongs_to :service_type
end
