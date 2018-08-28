class AddHiIndexToCollection < ActiveRecord::Migration
  def change
    add_index :collections, :dcterms_provenance, using: 'gin'
  end
end
