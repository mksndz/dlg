class RemoveCountFieldsFromBatchImport < ActiveRecord::Migration
  def change
    change_table :batch_imports do |t|
      t.remove :added
      t.remove :updated
      t.remove :failed
    end
  end
end
