class AddIdsFieldToBatchImport < ActiveRecord::Migration
  def change

    change_table :batch_imports do |t|

      t.integer :item_ids, default: [], array: true, null: false

      t.remove :xml
      t.string :xml, null: true

    end

  end
end
