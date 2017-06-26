class MainController < ApplicationController
  def index
    range = DateTime.current.beginning_of_day..DateTime.current.end_of_day
    @collected = OrderPayment.select("COALESCE(sum(amount),0) as amount").where(payment_stamp: range).first.amount rescue 0
    @billed = OrderEntry.select("COALESCE(sum(full_price),0) as amount").where(order_date: range).first.amount rescue 0
    @registrations = Patient.select("COALESCE(count(*),0) as number").where(date_created: range).first.number rescue 0
    @cash_payments = OrderPayment.select("COALESCE(count(*),0) as number").where(payment_stamp: range, payment_mode: "CASH").first.number rescue 0
    @pending = @billed - @collected

  end
end
