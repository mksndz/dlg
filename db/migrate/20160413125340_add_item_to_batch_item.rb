class AddItemToBatchItem < ActiveRecord::Migration
  def change
    change_table :batch_items do |t|
      t.references :item, index: true
    end
  end
end
