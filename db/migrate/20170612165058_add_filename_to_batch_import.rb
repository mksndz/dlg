class AddFilenameToBatchImport < ActiveRecord::Migration
  def change
    change_table :batch_imports do |t|
      t.string :file_name, null: true
    end
  end
end
