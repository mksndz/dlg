class AddRecordIdField < ActiveRecord::Migration
  def change
    change_table :items do |t|
      t.string :record_id, null: false, index: true, default: ''
    end
    change_table :collections do |t|
      t.string :record_id, null: false, index: true, default: ''
    end
    change_table :batch_items do |t|
      t.string :record_id, null: false, index: true, default: ''
    end

  end
end
