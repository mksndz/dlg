class RemoveLicenseField < ActiveRecord::Migration
  def change
    remove_column :items, :dcterms_license
    remove_column :batch_items, :dcterms_license
  end
end
