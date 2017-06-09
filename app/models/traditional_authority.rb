class TraditionalAuthority < ActiveRecord::Base
  establish_connection Registration
  self.table_name = "dde_traditional_authority"
  self.primary_key = "traditional_authority_id"

  belongs_to :district

end
