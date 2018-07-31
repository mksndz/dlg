# Migration to create new FulltextIngest model
class AddFulltextIngest < ActiveRecord::Migration
  def change
    create_table :fulltext_ingests do |t|
      t.string :title
      t.string :description
      t.string :file
      t.json :results, default: {}
      t.references :user
      t.datetime :queued_at
      t.datetime :finished_at
      t.datetime :undone_at
      t.timestamps
    end
  end
end
