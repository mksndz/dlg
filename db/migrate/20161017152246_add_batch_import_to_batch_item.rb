class AddBatchImportToBatchItem < ActiveRecord::Migration
  def change

    change_table :batch_items do |t|
      t.references :batch_import, index: true
    end

    change_table :batch_imports do |t|
      t.integer :batch_items_count
      t.datetime :completed_at
    end

  end
end
