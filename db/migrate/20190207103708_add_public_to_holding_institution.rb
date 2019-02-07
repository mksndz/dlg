# add public flag to holding institutions
class AddPublicToHoldingInstitution < ActiveRecord::Migration
  def change
    add_column :holding_institutions, :public, :boolean, default: true
  end
end
