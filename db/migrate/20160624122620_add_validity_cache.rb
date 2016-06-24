class AddValidityCache < ActiveRecord::Migration
  def change

    change_table :items do |t|
      t.boolean :valid_item, null: false, default: false
      t.index :valid_item
    end

    change_table :batch_items do |t|
      t.boolean :valid_item, null: false, default: false
      t.index :valid_item
    end

  end
end
