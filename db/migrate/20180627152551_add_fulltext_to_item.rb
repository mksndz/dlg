# Adds a simple text field to hold full-text/OCR data to an Item (and BatchItem)
# record
class AddFulltextToItem < ActiveRecord::Migration
  def change
    add_column :items, :fulltext, :text, null: true
    add_column :batch_items, :fulltext, :text, null: true
  end
end
