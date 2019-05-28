# Migration to Add scrubbed content column to CollectionResources Table
class AddScrubbedHtmlToCollectionResource < ActiveRecord::Migration
  def change
    change_table :collection_resources do |t|
      t.text :scrubbed_content
      t.rename :content, :raw_content
    end
  end
end
