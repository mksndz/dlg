class AddIngesterRoles < ActiveRecord::Migration
  def change
    add_column :users, :is_fulltext_ingester, :boolean, null: false, default: false
    add_column :users, :is_page_ingester, :boolean, null: false, default: false
  end
end
