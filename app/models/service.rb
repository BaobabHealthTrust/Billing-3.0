class Service < ActiveRecord::Base
  default_scope {-> { where "#{self.table_name}.voided = false"}}
  default_scope {-> {order 'rank ASC, name ASC' }}
  has_many :service_prices
  has_many :service_price_histories
  belongs_to :service_type

  def get_price(location)
    self.service_prices.select(:price,:price_id).where(price_type: location).first rescue nil
  end
end
