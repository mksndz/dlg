class CreateBatchImports < ActiveRecord::Migration
  def change
    create_table :batch_imports do |t|

      t.string      :xml,     null: false
      t.string      :type,    null: false
      t.integer     :added
      t.integer     :errors
      t.references  :user,    null: false
      t.references  :batch,   null: false
      t.timestamps            null: false

    end
  end
end
