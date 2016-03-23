class TransferUserStuffToAdmin < ActiveRecord::Migration
  def change

    change_table :users do |t|
      t.remove :creator_id
    end

    drop_join_table :roles, :users

    change_table :admins do |t|
      t.references :creator
      t.index :creator_id
    end

    create_join_table :roles, :admins do |t|
      t.index [:role_id, :admin_id]
      t.index [:admin_id, :role_id]
    end

  end
end
