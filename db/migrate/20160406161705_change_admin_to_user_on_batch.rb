class ChangeAdminToUserOnBatch < ActiveRecord::Migration
  def change
    change_table :batches do |t|
      t.remove :admin_id
      t.references :user
      t.index :user_id
    end
  end
end
