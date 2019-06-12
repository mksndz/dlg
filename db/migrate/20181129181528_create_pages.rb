# create Page as optional components of an Item
class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.references :item
      t.text :fulltext
      t.string :title
      t.string :number
      t.timestamps null: false
    end
  end
end
