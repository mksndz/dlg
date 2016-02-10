class AddAndRemoveItemFields < ActiveRecord::Migration
  def change
    change_table :items do |t|

      # remove in_georgia flag, as it belongs on the Collection
      t.remove :in_georgia

      # add missing DC fields
      t.text :dc_creator,  array: true, null: false, default: []
      t.text :dc_language, array: true, null: false, default: []
      t.text :dc_relation, array: true, null: false, default: []

    end
  end
end
