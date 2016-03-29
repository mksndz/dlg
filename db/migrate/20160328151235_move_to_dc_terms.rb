class MoveToDcTerms < ActiveRecord::Migration
  def change
    change_table :items do |t|

      t.remove :dc_title
      t.remove :dc_publisher
      t.remove :dc_contributor
      t.remove :dc_coverage_temporal
      t.remove :dc_coverage_spatial
      t.remove :dc_subject
      t.remove :dc_source
      t.remove :dc_type
      t.remove :dc_creator
      t.remove :dc_language
      t.remove :dc_description

      t.text :dcterms_is_part_of, array: true, null: false, default: []
      t.text :dcterms_contributor, array: true, null: false, default: []
      t.text :dcterms_creator, array: true, null: false, default: []
      t.text :dcterms_description, array: true, null: false, default: []
      t.text :dcterms_extent, array: true, null: false, default: []
      t.text :dcterms_medium, array: true, null: false, default: []
      t.text :dcterms_identifier, array: true, null: false, default: []
      t.text :dcterms_language, array: true, null: false, default: []
      t.text :dcterms_spatial, array: true, null: false, default: []
      t.text :dcterms_publisher, array: true, null: false, default: []
      t.text :dcterms_access_right, array: true, null: false, default: []
      t.text :dcterms_rights_holder, array: true, null: false, default: []
      t.text :dcterms_subject, array: true, null: false, default: []
      t.text :dcterms_temporal, array: true, null: false, default: []
      t.text :dcterms_title, array: true, null: false, default: []
      t.text :dcterms_type, array: true, null: false, default: []
      t.text :dcterms_is_shown_at, array: true, null: false, default: []
      t.text :dcterms_provenance, array: true, null: false, default: []
      t.text :dcterms_license, array: true, null: false, default: []

    end

    change_table :batch_items do |t|

      t.remove :dc_title
      t.remove :dc_publisher
      t.remove :dc_contributor
      t.remove :dc_coverage_temporal
      t.remove :dc_coverage_spatial
      t.remove :dc_subject
      t.remove :dc_source
      t.remove :dc_type
      t.remove :dc_creator
      t.remove :dc_language
      t.remove :dc_description

      t.text :dcterms_is_part_of, array: true, null: false, default: []
      t.text :dcterms_contributor, array: true, null: false, default: []
      t.text :dcterms_creator, array: true, null: false, default: []
      t.text :dcterms_description, array: true, null: false, default: []
      t.text :dcterms_extent, array: true, null: false, default: []
      t.text :dcterms_medium, array: true, null: false, default: []
      t.text :dcterms_identifier, array: true, null: false, default: []
      t.text :dcterms_language, array: true, null: false, default: []
      t.text :dcterms_spatial, array: true, null: false, default: []
      t.text :dcterms_publisher, array: true, null: false, default: []
      t.text :dcterms_access_right, array: true, null: false, default: []
      t.text :dcterms_rights_holder, array: true, null: false, default: []
      t.text :dcterms_subject, array: true, null: false, default: []
      t.text :dcterms_temporal, array: true, null: false, default: []
      t.text :dcterms_title, array: true, null: false, default: []
      t.text :dcterms_type, array: true, null: false, default: []
      t.text :dcterms_is_shown_at, array: true, null: false, default: []
      t.text :dcterms_provenance, array: true, null: false, default: []
      t.text :dcterms_license, array: true, null: false, default: []

    end
  end
end
