# remove provenance field (replaced by HI relation)
class RemoveProvenance < ActiveRecord::Migration
  def change
    remove_column :collections, :dcterms_provenance
    remove_column :items, :dcterms_provenance
    remove_column :batch_items, :dcterms_provenance
  end
end
