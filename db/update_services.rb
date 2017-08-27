creator = User.first

puts 'Loading services and their prices'
CSV.foreach("#{Rails.root}/db/updated_list.csv",{:headers=>:first_row, :col_sep => ","}) do |row|
  type = ServiceType.where(name: row[1]).first.id rescue nil
  next if type.blank?
  service = Service.where({name: row[0], service_type_id: type}).first_or_initialize
  service.creator = creator.id
  service.save

  if !row[2].blank? || row[2] == '0'
    service_price = ServicePrice.where(service_id: service.id,price_type: 'General').first_or_initialize
    service_price.price = (row[2].blank? ? 0.00 : row[2].to_f)
    service_price.creator = creator.id
    service_price.updated_by = creator.id
    service_price.save
  end

  if !row[3].blank? || row[3] == '0'
    service_price = ServicePrice.where(service_id: service.id,price_type: 'Private').first_or_initialize
    service_price.price = (row[3].blank? ? 0.00 : row[3].to_f)
    service_price.creator = creator.id
    service_price.updated_by = creator.id
    service_price.save
  end
end

puts 'Loading service panels'
CSV.foreach("#{Rails.root}/db/panel_seed.csv",{:headers=>:first_row, :col_sep => ","}) do |row|
  type = ServiceType.where(name: row[3]).first.id
  service_panel = ServicePanel.where({name: row[0], service_type_id: type}).first_or_initialize
  service_panel.creator = creator.id
  service_panel.voided = row[4]
  service_panel.save

  service = Service.where({name: row[1], service_type_id: type}).first
  next if service.blank?

  panel_detail = ServicePanelDetail.where(service_panel_id: service_panel.id).first_or_initialize
  panel_detail.service_id = service.id
  panel_detail.quantity = row[2]
  panel_detail.save
end