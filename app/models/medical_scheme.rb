class MedicalScheme < ActiveRecord::Base
  default_scope {-> { where "#{self.table_name}.retired = false" }}
  belongs_to :medical_scheme_provider, :foreign_key => :medical_scheme_provider
  has_one :user, :foreign_key => :creator

  def user_name
    User.find(self.creator).name
  end
end
