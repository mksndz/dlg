class AddLocalRightField < ActiveRecord::Migration
  def change

    change_table :items do |t|
      t.text :dlg_local_right, array: true, null: false, default: []
    end

    change_table :batch_items do |t|
      t.text :dlg_local_right, array: true, null: false, default: []
    end

  end
end
