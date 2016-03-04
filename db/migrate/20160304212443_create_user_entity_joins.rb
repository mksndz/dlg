class CreateUserEntityJoins < ActiveRecord::Migration
  def change
    create_join_table :users, :repositories do |t|
      t.index [:user_id, :repository_id]
      t.index [:repository_id, :user_id]
    end
    create_join_table :users, :collections do |t|
      t.index [:user_id, :collection_id]
      t.index [:collection_id, :user_id]
    end
  end
end
