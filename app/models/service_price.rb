class ServicePrice < ActiveRecord::Base

  belongs_to :service

  before_update :price_updated

  def price_updated
    ServicePriceHistory.create({:service_id => self.service_id, :price => self.price,
                                :price_type => self.price_type, :active_from => self.updated_at,
                                :active_to => Date.current, :creator => self.updated_by})
  end
end
