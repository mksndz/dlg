# add integer field to Item to cache number of associated pages
class AddPageCountToItem < ActiveRecord::Migration
  def change
    add_column :items, :pages_count, :integer
  end
end
