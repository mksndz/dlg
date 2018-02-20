class RemoveNotNullConstraintOnBatchItem < ActiveRecord::Migration
  def change
    change_column_null :batch_items, :collection_id, true
  end
end
