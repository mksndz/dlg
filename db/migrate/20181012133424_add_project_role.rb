# adds 'pm' role for users empowered to manage projects
class AddProjectRole < ActiveRecord::Migration
  def change
    add_column :users, :is_pm, :boolean, null: false, default: false
  end
end
