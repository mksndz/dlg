# add two fields to Holding Institution
class AddHoldingInstFields < ActiveRecord::Migration
  def change
    change_table :holding_institutions do |t|
      t.string :parent_institution
      t.text :notes
    end
  end
end
