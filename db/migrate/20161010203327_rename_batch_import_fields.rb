class RenameBatchImportFields < ActiveRecord::Migration
  def change
    change_table :batch_imports do |t|
      t.rename :errors, :failed
      t.rename :type, :format
    end
  end
end
