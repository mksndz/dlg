class AddBatchToItem < ActiveRecord::Migration
  def change

    change_table :items do |t|

      t.references :batch, null: true, index: true, foreign_key: true

    end

  end
end
