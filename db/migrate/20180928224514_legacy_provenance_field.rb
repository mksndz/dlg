# copies text provenance data to temporary legacy field
class LegacyProvenanceField < ActiveRecord::Migration
  def change
    rename_column :items, :dcterms_provenance, :legacy_dcterms_provenance
    rename_column :batch_items, :dcterms_provenance, :legacy_dcterms_provenance
    rename_column :collections, :dcterms_provenance, :legacy_dcterms_provenance
  end
end
