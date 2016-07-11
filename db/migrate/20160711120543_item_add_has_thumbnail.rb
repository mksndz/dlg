class ItemAddHasThumbnail < ActiveRecord::Migration
  def change
    add_column :items, :has_thumbnail, :boolean, default: false, null: false
  end
end
