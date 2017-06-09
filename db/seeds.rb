# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

creator = User.first
service_types = %w[Radiology Pharmacy Laboratory Surgery Mortuary Maternity Consultation Dental Ophthalmology]

(service_types || []).each do |type|
  service_type = ServiceType.first_or_create(name: type)
  service_type.creator = creator.id
  service_type.save
end
