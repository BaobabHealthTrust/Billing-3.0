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
end
