class AddUpdatedCountToBatchImport < ActiveRecord::Migration
  def change
    change_table :batch_imports do |t|
      t.integer :updated
    end
  end
end
