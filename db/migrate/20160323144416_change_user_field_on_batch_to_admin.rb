class ChangeUserFieldOnBatchToAdmin < ActiveRecord::Migration
  def change
    change_table :batches do |t|
      t.remove :user_id
      t.references :admin
      t.index :admin_id
    end
  end
end
