class TransferMetaEntityRelationsToAdmin < ActiveRecord::Migration
  def change

    drop_join_table :collections, :users
    drop_join_table :repositories, :users

    create_join_table :collections, :admins do |t|
      t.index [:collection_id, :admin_id]
      t.index [:admin_id, :collection_id]
    end

    create_join_table :repositories, :admins do |t|
      t.index [:repository_id, :admin_id]
      t.index [:admin_id, :repository_id]
    end

  end
end
