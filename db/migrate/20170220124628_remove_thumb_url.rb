class RemoveThumbUrl < ActiveRecord::Migration
  def change

    change_table :items do |t|
      t.remove :thumbnail_url
    end

    change_table :batch_items do |t|
      t.remove :thumbnail_url
    end

    change_table :collections do |t|
      t.remove :thumbnail_url
    end

  end
end
