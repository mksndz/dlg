class AddImageToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :image, :string
  end
end
