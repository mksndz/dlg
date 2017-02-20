class RenameThumbnailField < ActiveRecord::Migration
  def change

    change_table :repositories do |t|
      t.rename :thumbnail_url, :thumbnail_path
    end

  end
end
