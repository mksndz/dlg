class ChangeItemOtherCollections < ActiveRecord::Migration
  def change
    remove_column :items, :other_collections
    add_column :items, :other_collections, :string, array: true, default: []
  end
end
