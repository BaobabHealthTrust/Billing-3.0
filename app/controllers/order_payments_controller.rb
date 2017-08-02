class OrderPaymentsController < ApplicationController
  def show

  end
  def create

    if params[:order_entries].blank?
      range = Date.current.beginning_of_day..Date.current.end_of_day
      orders = OrderEntry.select(:order_entry_id, :full_price,:amount_paid).where(
                                "patient_id = ? and amount_paid < full_price", params[:order_payment][:patient_id])

    else
      orders = OrderEntry.select(:order_entry_id, :full_price,:amount_paid).where(patient_id: params[:order_payment][:patient_id],
                                                                                  order_entry_id: params[:order_entries].split(','))
    end

    amount = params[:order_payment][:amount].to_f
    if amount > 0
      Receipt.transaction do
        new_receipt = Receipt.create(payment_mode: params[:order_payment][:mode],
                                     cashier: User.find(params[:creator]),
                                     patient_id: params[:order_payment][:patient_id])

        (orders || []).each do |entry|
          break if amount == 0
          order_status = entry.status
          if order_status[:bill_status] == "PAID"
            next
          else
            amount_due = (entry.full_price - order_status[:amount])
            pay_amount =  (amount_due <= amount ? amount_due : amount)

            entry.amount_paid += pay_amount
            entry.save

            OrderPayment.create(order_entry_id: entry.id, cashier: User.find(params[:creator]),
                                              amount: pay_amount, receipt_number: new_receipt.receipt_number )

            amount -= pay_amount

          end
        end
        #Print receipt of transaction
        print_and_redirect("/order_payments/print_receipt?change=#{amount}&ids=#{new_receipt.receipt_number}",
                           "/patients/#{params[:order_payment][:patient_id]}")
      end

    else
      redirect_to "/patients/#{params[:order_payment][:patient_id]}" and return
    end

  end

  def print_receipt
    ids = params[:ids].split(',') rescue params[:id]
    change = (params[:change].to_f || 0)
    if ids.length > 1
      print_string = ""
      (ids || []).each do |receipt|
        print_string += "#{Misc.print_receipt(receipt, change)}\n"
      end
    else
      print_string = Misc.print_receipt(ids, change)
    end


    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false,
              :filename=>"#{(0..8).map { (65 + rand(26)).chr }.join}.lbs", :disposition => "inline")

  end

  def void
    #This function cancels payments and reprints the receipt
    entries = OrderEntry.where(order_entry_id: params[:id].split(','))

    if entries.blank?
      redirect_to "/"
    else
      receipt = []
      #voiding selected entries
      (entries || []).each do |entry|
        (entry.order_payments || []).each do |payment|
          payment.void("Wrong entry", current_user)
          receipt << payment.receipt_number
        end
        entry.void("Wrong entry", current_user.id)
      end

      if receipt.blank?
        redirect_to entries.first.patient
      else
        other_payments = OrderPayment.where(receipt_number: receipt)
        old_receipt = Receipt.where(receipt_number: receipt)
        old_receipt.update_all(voided: true, voided_by: current_user)

        if other_payments.blank?
          redirect_to entries.first.patient and return
        else
          Receipt.transaction do
            new_receipt = Receipt.create(payment_mode: old_receipt.first.payment_mode,
                                         patient_id: other_payments.first.order_entry.patient_id, cashier: current_user)
            OrderPayment.where(receipt_number: receipt).update_all(receipt_number: new_receipt.receipt_number)

            print_and_redirect("/order_payments/print_receipt?ids=#{new_receipt.receipt_number}",
                               "/patients/#{entries.first.patient_id}")
          end
        end
      end

    end
  end
end
