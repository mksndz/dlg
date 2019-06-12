# adds file type string field to Page model
class AddFileTypeToPage < ActiveRecord::Migration
  def change
    add_column :pages, :file_type, :string
  end
end
