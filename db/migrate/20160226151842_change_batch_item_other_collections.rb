class ChangeBatchItemOtherCollections < ActiveRecord::Migration
  def change
    remove_column :batch_items, :other_collections
    add_column :batch_items, :other_collections, :string, array: true, default: []
  end
end
