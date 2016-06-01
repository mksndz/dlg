class ChangeOtherCollFieldOnItem < ActiveRecord::Migration
  def change

    remove_column :batch_items, :other_collections
    add_column :batch_items, :other_collections, :integer, array: true, default: []
    add_index :batch_items, :other_collections

    remove_column :items, :other_collections
    add_column :items, :other_collections, :integer, array: true, default: []
    add_index :items, :other_collections

  end
end
