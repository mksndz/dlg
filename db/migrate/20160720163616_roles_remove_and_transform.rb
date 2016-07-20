class RolesRemoveAndTransform < ActiveRecord::Migration

  def up

    drop_join_table :roles, :users
    drop_table :roles

    change_table :users do |t|
    end

  end

  def down

    create_table :roles do |t|
      t.string :name
      t.timestamps null: false
    end

    create_join_table :roles, :users

  end

end
