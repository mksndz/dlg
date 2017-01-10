class AddNewFieldsToItem < ActiveRecord::Migration
  def change

    change_table :items do |t|

      t.boolean :remote, null: false, index: true, default: true
      t.text    :dlg_subject_personal, array: true, null: false, default: []

    end

    change_table :batch_items do |t|

      t.boolean :remote, null: false, index: true, default: true
      t.text    :dlg_subject_personal, array: true, null: false, default: []

    end

  end
end
