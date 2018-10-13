# change storage_used field on Project to accept decimal values
class ChangeProjectStorageField < ActiveRecord::Migration
  def change
    change_column :projects, :storage_used, :float
  end
end
