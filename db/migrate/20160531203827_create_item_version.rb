class CreateItemVersion < ActiveRecord::Migration
  def change
    rename_table :versions, :item_versions
  end
end
