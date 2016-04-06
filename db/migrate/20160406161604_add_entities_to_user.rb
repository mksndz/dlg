class AddEntitiesToUser < ActiveRecord::Migration
  def change

    drop_join_table :collections, :admins
    drop_join_table :repositories, :admins

    create_join_table :collections, :users do |t|
      t.index [:collection_id, :user_id]
      t.index [:user_id, :collection_id]
    end

    create_join_table :repositories, :users do |t|
      t.index [:repository_id, :user_id]
      t.index [:user_id, :repository_id]
    end
    
  end
end
