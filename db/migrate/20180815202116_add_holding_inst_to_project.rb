# link Project to Holding Institution
class AddHoldingInstToProject < ActiveRecord::Migration
  def change
    change_table :projects do |t|
      t.references :holding_institution
    end
  end
end
