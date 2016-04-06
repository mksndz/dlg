class AddRolesToUser < ActiveRecord::Migration
  def change

    change_table :users do |t|
      t.references :creator
      t.index :creator_id
    end

    drop_join_table :roles, :admins

    create_join_table :roles, :users do |t|
      t.index [:role_id, :user_id]
      t.index [:user_id, :role_id]
    end

  end
end
