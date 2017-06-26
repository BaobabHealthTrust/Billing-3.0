class UserRole < ActiveRecord::Base
  establish_connection Registration
  self.table_name = :user_role
  self.primary_keys = :role, :user_id
  include Openmrs

  belongs_to :user, -> {where "retired = false"}, :foreign_key => :user_id
end
