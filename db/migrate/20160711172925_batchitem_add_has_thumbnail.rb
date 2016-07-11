class BatchitemAddHasThumbnail < ActiveRecord::Migration
  def change
    add_column :batch_items, :has_thumbnail, :boolean, default: false, null: false
  end
end
