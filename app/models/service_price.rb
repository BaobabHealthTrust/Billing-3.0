class ServicePrice < ActiveRecord::Base

  belongs_to :service

  before_update :on_update

  def on_update
    ServicePriceHistory.create({:service_id => self.service_id, :price => self.price,
                                :price_type => self.price_type, :active_from => self.date_updated,
                                :active_to => Date.current})
  end
end
