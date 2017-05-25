class SetLocalToDefaultFalse < ActiveRecord::Migration
  def change
    change_column :items, :local, :boolean, default: :false
    change_column :batch_items, :local, :boolean, default: :false
  end
end
