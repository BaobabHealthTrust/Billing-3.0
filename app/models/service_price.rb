class ServicePrice < ActiveRecord::Base
  default_scope {-> { where "#{self.table_name}.voided = false" }}
  belongs_to :service
  has_many :service_price_histories

  before_update :price_updated

  def price_updated

    ServicePriceHistory.create({:service_id => self.service_id, :price => self.price,
                                :price_type => self.price_type, :active_from => self.updated_at,
                                :active_to => Date.current, :creator => self.updated_by})
  end
end
