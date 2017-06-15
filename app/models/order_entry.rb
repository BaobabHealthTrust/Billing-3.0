class OrderEntry < ActiveRecord::Base
  attr_accessor :service_offered, :service_point
  before_create :complete_record

  belongs_to :service, :foreign_key => :service_id
  belongs_to :patient, :foreign_key => :patient_id
  belongs_to :user, :foreign_key => :cashier


  def description
    self.service.name
  end

  def complete_record
    service = Service.find_by_name(self.service_offered)
    self.service_id = service.id
    self.full_price= (service.service_prices.select(:price).where(price_type: self.service_point).first.price * self.quantity) rescue 0
  end

  def void(reason)
    self.voided = true
    self.voided_by= current_user
    self.voided_reason= reason
    self.save
  end
end
