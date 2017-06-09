class Service < ActiveRecord::Base
  has_many :service_prices
  has_many :service_price_histories
  belongs_to :service_type
end
