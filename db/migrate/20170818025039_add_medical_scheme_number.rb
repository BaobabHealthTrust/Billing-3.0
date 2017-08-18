class AddMedicalSchemeNumber < ActiveRecord::Migration
  def change
    change_table :patient_accounts do |p|
      p.string :scheme_number
    end
  end

end
