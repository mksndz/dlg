class AddViewerRoleToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_viewer, :boolean, null: false, default: false
  end
end
