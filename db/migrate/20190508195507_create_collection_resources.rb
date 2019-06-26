# Create CollectionResource table
class CreateCollectionResources < ActiveRecord::Migration
  def change
    create_table :collection_resources do |t|
      t.string :slug
      t.integer :position
      t.string :title
      t.text :content

      t.timestamps null: false

      t.references :collection

    end
  end
end
