class OrderPaymentsController < ApplicationController
  def show

  end
  def create
    new_payments = []

    if params[:order_entries].blank?
      range = Date.current.beginning_of_day..Date.current.end_of_day
      orders = OrderEntry.select(:order_entry_id, :full_price,:amount_paid).where(patient_id: params[:order_payment][:patient_id],
                                                                     order_date: range)

      amount = params[:order_payment][:amount].to_f

      (orders || []).each do |entry|
        break if amount == 0
        order_status = entry.status
        if order_status[:bill_status] == "PAID"
          next
        else
          amount_due = (entry.full_price - order_status[:amount])
          pay_amount =  (amount_due <= amount ? amount_due : amount)

          OrderEntry.transaction do
            entry.amount_paid += pay_amount
            entry.save

            new_payment = OrderPayment.create(order_entry_id: entry.id, cashier: User.find(params[:creator]),
                                              amount: pay_amount , payment_mode: params[:order_payment][:mode])


            amount -= pay_amount
            new_payments << new_payment.id
          end
        end
      end
    else

    end

    #if print barcode
    print_and_redirect("/order_payments/print_receipt?change=#{amount}&ids=#{new_payments.join(',')}",
                       "/patients/#{params[:order_payment][:patient_id]}")


  end

  def print_receipt
    ids = params[:ids].split(',') rescue params[:id]
    print_string = Misc.print_receipt(ids)

    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false,
              :filename=>"#{(0..8).map { (65 + rand(26)).chr }.join}.lbl", :disposition => "inline")

  end

  def void
    #This function cancels payments and reprints the receipt
    entries = OrderEntry.where(order_entry_id: params[:id].split(','))

    if entries.blank?
      redirect_to "/"
    else
      date = ""
      (entries || []).each do |entry|
        (entry.order_payments || []).each do |payment|
          payment.void("Wrong entry", current_user.id)
          date = payment.payment_stamp
        end
      end

      if date.blank?
        redirect_to entries.first.patient
      else
        range = date.beginning_of_day..date.end_of_day
        payments_on_day = OrderEntry.select(:order_entry_id).where(patient_id: entries.first.patient_id,
                                                                       order_date: range).inject([]){|collection,x| collection + x.order_payments.collect{|r| r.order_payment_id}}

        if payments_on_day.blank?
          redirect_to entries.first.patient
        else
          print_and_redirect("/order_payments/print_receipt?ids=#{payments_on_day.join(',')}",
                             "/patients/#{entries.first.patient_id}")
        end
      end

    end
  end
end
