class RemoveAccessRightField < ActiveRecord::Migration
  def change
    remove_column :items, :dcterms_access_right
    remove_column :batch_items, :dcterms_access_right
  end
end
