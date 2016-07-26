class AddLocalRightToColl < ActiveRecord::Migration
  def change

    change_table :collections do |t|
      t.text :dlg_local_right, array: true, null: false, default: []
    end

  end
end