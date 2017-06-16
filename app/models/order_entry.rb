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

  def complete_record
    service = Service.find_by_name(self.service_offered)
    self.service_id = service.id
    self.full_price= (service.service_prices.select(:price).where(price_type: self.service_point).first.price * self.quantity) rescue 0
  end

  def status
    amount_paid = self.order_payments.select("COALESCE(SUM(amount),0) as amount").first.amount
    if (amount_paid > 0 && amount_paid < self.full_price)
      return {bill_status: "PARTIAL PAYMENT", amount: amount_paid}
    elsif (amount_paid > self.full_price)
      return {bill_status: "PAID", amount: amount_paid}
    else
      return {bill_status: "UNPAID", amount: amount_paid}
    end
  end

  def void(reason)
    self.voided = true
    self.voided_by= current_user
    self.voided_reason= reason
    self.save
  end
end
