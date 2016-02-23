class CreateRolesUsersTable < ActiveRecord::Migration
  def change
    create_table :roles_users do |t|
      t.integer :role_id, index: true
      t.integer :user_id, index: true
    end
  end
end
