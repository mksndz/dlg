class ChangeXmlFieldTypeOnBatchImport < ActiveRecord::Migration
  def change
    change_table :batch_imports do |t|
      t.change :xml, :text
    end
  end
end
