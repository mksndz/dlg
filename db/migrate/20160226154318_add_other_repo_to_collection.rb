class AddOtherRepoToCollection < ActiveRecord::Migration
  def change
    remove_column :collections, :other_repositories
    add_column :collections, :other_repositories, :string, array: true, default: []
  end
end
