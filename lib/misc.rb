#This module includes all functions that may come in handy to do avoid code repetitions
module Misc
  def self.patient_national_id_label(patient)

    return unless patient.national_id
    sex =  "(#{patient.gender.upcase})"

    address = patient.current_district rescue ""
    if address.blank?
      address = patient.current_residence rescue ""
    else
      address += ", " + patient.current_residence unless patient.current_residence.blank?
    end

    label = ZebraPrinter::StandardLabel.new
    label.font_size = 2
    label.font_horizontal_multiplier = 2
    label.font_vertical_multiplier = 2
    label.left_margin = 50
    label.draw_barcode(50,180,0,1,5,15,120,false,"#{patient.national_id}")
    label.draw_multi_text("#{patient.full_name.titleize}")
    label.draw_multi_text("#{dash_formatter(patient.national_id)} #{patient.presentable_dob}#{sex}")
    label.draw_multi_text("#{address}" ) unless address.blank?
    label.print(1)
  end

  def self.dash_formatter(id)
    return "" if id.blank?
    if id.length > 9
      return id[0..(id.length/3)] + "-" +id[1 +(id.length/3)..(id.length/3)*2]+ "-" +id[1 +2*(id.length/3)..id.length]
    else
      return id[0..(id.length/2) -1] + "-" +id[(id.length/2)..id.length]
    end
  end

  def self.print_receipt(ids)
    payments = OrderPayment.where(order_payment_id: ids)
    (payments || []).each do |payment|

    end

    patient_name = payments.first.order_entry.patient.full_name
    cashier = payments.first.cashier.name

    label = ZebraPrinter::StandardLabel.new
    label.font_size = 2
    label.font_horizontal_multiplier = 2
    label.font_vertical_multiplier = 2
    label.left_margin = 50
    label.draw_multi_text("#{'Daeyang Luke Mission Hospital'.titleize}")
    label.draw_multi_text("#{'P. O. Box 30330, LL3'.titleize}")
    label.draw_multi_text("Date: #{Date.current.strftime('%d %b %Y')}")
    label.draw_multi_text("Patient: #{patient_name.titleize}")

    label.draw_multi_text("Issued By: #{cashier.titleize}")
    label.print(1)
  end
end