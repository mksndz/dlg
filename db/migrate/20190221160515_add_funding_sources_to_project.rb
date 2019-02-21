# Add multivalued Funding Source field to Project
class AddFundingSourcesToProject < ActiveRecord::Migration
  def change
    change_table :projects do |t|
      t.string :funding_sources, array: true, null: false, default: []
    end
  end
end
