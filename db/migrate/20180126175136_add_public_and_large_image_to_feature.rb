# add boolean "public" and image attachment "large image" to Feature
class AddPublicAndLargeImageToFeature < ActiveRecord::Migration
  def change
    change_table :features do |t|
      t.string :large_image
      t.boolean :public, default: false
    end
  end
end
