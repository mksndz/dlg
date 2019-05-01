# migration to create Page Ingest entity
class CreatePageIngest < ActiveRecord::Migration
  def change
    create_table :page_ingests do |t|
      t.references :user
      t.string :title
      t.string :description
      t.string :file
      t.json :results_json, default: {}
      t.json :page_json, default: {}
      t.datetime :queued_at
      t.datetime :finished_at
      t.timestamps
    end
  end
end
