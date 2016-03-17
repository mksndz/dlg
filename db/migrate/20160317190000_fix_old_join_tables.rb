class FixOldJoinTables < ActiveRecord::Migration
  def change

    drop_table :collections_subjects
    drop_table :roles_users

    create_join_table :roles, :users do |t|
      t.index [:user_id, :role_id]
      t.index [:role_id, :user_id]
    end
    create_join_table :collections, :subjects do |t|
      t.index [:collection_id, :subject_id]
      t.index [:subject_id, :collection_id]
    end
  end
end
