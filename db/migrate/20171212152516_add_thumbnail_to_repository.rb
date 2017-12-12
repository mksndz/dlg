class AddThumbnailToRepository < ActiveRecord::Migration
  def change
    remove_column :repositories, :thumbnail_path
    add_column :repositories, :thumbnail, :string
  end
end
