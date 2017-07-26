class AddDbIdMatchToBatchImport < ActiveRecord::Migration
  def change
    change_table :batch_imports do |t|
      t.boolean :match_on_id, default: :false, null: false
    end
  end
end
