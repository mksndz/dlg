# adds to HoldingInstitution fields for public contact information
class AddContectFieldsToInst < ActiveRecord::Migration
  def change
    change_table :holding_institutions do |t|
      t.rename :contact_information, :public_contact_address
      t.string :public_contact_email
      t.string :public_contact_phone
    end
  end
end
