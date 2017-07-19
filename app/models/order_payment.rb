class OrderPayment < ActiveRecord::Base
  default_scope {-> { where "#{self.table_name}.voided = false" }}
  belongs_to :order_entry, :foreign_key => :order_entry_id
  has_one :patient, :through => :order_entry
  has_one :service, :through => :order_entry
  belongs_to :cashier, class_name: "User", :foreign_key => :cashier
  before_create :complete_record

  def complete_record
    self.payment_stamp= DateTime.current if self.payment_stamp.blank?
  end

  def clinic_type
      self.order_entry.location == 788 ? "general" : "private"
  end

  def service_category
    self.order_entry.service.service_type_id
  end

  def void(reason,user)
    OrderPayment.transaction do
      order_entry =  self.order_entry
      order_entry.amount_paid -= self.amount
      order_entry.save

      self.voided = true
      self.voided_by= user
      self.voided_reason= reason
      self.save
    end

  end
end
