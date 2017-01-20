class AddMoreThumbnails < ActiveRecord::Migration
  def change

    change_table :items do |t|
      t.string :thumbnail_url, null: true
    end

    change_table :batch_items do |t|
      t.string :thumbnail_url, null: true
    end

    change_table :collections do |t|
      t.string :thumbnail_url, null: true
    end

    change_table :repositories do |t|
      t.string :thumbnail_url, null: true
    end

  end
end
