class ChangeVersionFieldToJson < ActiveRecord::Migration
  def change
    change_table :item_versions do |t|
      t.remove :object
      t.json :object
    end
  end
end
