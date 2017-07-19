class OrderEntry < ActiveRecord::Base
  default_scope {-> { where "#{self.table_name}.voided = false" }}
  belongs_to :service, :foreign_key => :service_id
  belongs_to :patient, :foreign_key => :patient_id
  belongs_to :user, :foreign_key => :cashier
  has_many :order_payments, :foreign_key => :order_entry_id
  attr_accessor :service_offered, :service_point

  before_create :complete_record

  def description
    self.service.name
  end

  def clinic_type
    self.location == 788 ? "general" : "private"
  end

  def complete_record
    service = (self.service_id.blank? ? Service.find_by_name(self.service_offered) : self.service)
    self.service_id = service.id
    self.full_price= (service.service_prices.select(:price).where(price_type: self.service_point).first.price * self.quantity) rescue 0
  end

  def status
    if (self.amount_paid > 0 && self.amount_paid < self.full_price)
      return {bill_status: "PARTIAL PAYMENT", amount: self.amount_paid}
    elsif (self.amount_paid >= self.full_price)
      return {bill_status: "PAID", amount: self.amount_paid}
    else
      return {bill_status: "UNPAID", amount: self.amount_paid}
    end
  end

  def void(reason,user)
    self.voided = true
    self.voided_by= user
    self.voided_reason= reason
    self.save
  end
end
