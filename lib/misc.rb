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

  def self.print_receipt(ids, change = 0)
    payments = OrderPayment.where(order_payment_id: ids)
    patient_name = payments.first.order_entry.patient.full_name
    cashier = payments.first.cashier.name
    text = []
    heading = ""
    heading += "#{get_config('facility_name').titleize}\n"
    heading += "#{get_config('facility_address')}\n"
    heading += "Date: #{Date.current.strftime('%d %b %Y')}\n"
    heading += "Patient: #{patient_name.titleize}\n"
    heading += "Issued By: #{cashier.titleize}\n"
    total = 0
    (payments || []).each do |payment|
      text << [payment.service.name, local_currency(payment.amount)]
      total += payment.amount
    end

    label = ZebraPrinter::Label.new(616,203,'056',true)
    label.font_size = 3
    label.font_horizontal_multiplier = 1
    label.font_vertical_multiplier = 1
    label.draw_multi_text(heading)
    label.draw_line(label.x,label.y,566,2)
    label.y+=10
    label.draw_table(text, [[370, "left"], [200, "right"]])
    label.draw_line(label.x,label.y,566,2)
    label.y+=10
    label.draw_table([['Total: ',local_currency(total)]], [[370, "left"], [200, "right"]])
    label.draw_table([['Cash: ',local_currency((total+change))]], [[370, "left"], [200, "right"]])
    label.draw_table([['Change: ',local_currency(change)]], [[370, "left"], [200, "right"]])
    label.draw_line(label.x,label.y,566,7,1)
    label.print(1)
  end

  def self.get_config(prop)
    YAML.load_file("#{Rails.root}/config/application.yml")[prop]
  end

  def self.local_currency(amount)
    return ActiveSupport::NumberHelper::number_to_currency(amount,{precision: 2,unit: 'MWK '})
  end
end