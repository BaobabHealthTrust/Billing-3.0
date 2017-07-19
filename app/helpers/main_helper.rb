module MainHelper
  def report_options
    options = %w[Daily Weekly Monthly Range]
    return options
  end

  def income_summary(data)
    records = []

    (data || []).each do |y|
      order = OrderEntry.find_by_sql("SELECT service_id, full_price FROM order_entries where order_entry_id = #{y.order_entry_id}").first rescue nil
      next if order.blank?
      records << {service: order.description, received_by: y.cashier.username, paid: y.amount,
                  bill: order.full_price, voided: y.voided}
    end

    return records
  end

  def cash_summary(data)
    records = Hash[*ServiceType.all.collect{|x| [x.id,{name: x.name, private: 0, general: 0}]}.flatten(1)]
    (data || []).each do |payment|
      entry = payment.order_entry
      records[entry.service.service_type_id][entry.clinic_type.to_sym] +=payment.amount
    end
    return records
  end
end
