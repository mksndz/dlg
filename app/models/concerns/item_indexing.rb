module ItemIndexing
  extend ActiveSupport::Concern

  included do

    searchable do

      string :slug, stored: true

      # set empty proxy id field so sunspot knows about it
      # value is set prior to save
      # sunspot search will not work without this, but indexing will
      # see monkeypatch @ config/initializers/sunspot_indexer_id.rb
      string :sunspot_id, stored: true do
        ''
      end

      boolean :dpla
      boolean :public

      string :in_collection, stored: true do
        collection ? collection.display_title : ''
      end

      # DC Fields for Searching and Display
      text :dc_title,       stored: true
      text :dc_format,      stored: true
      text :dc_publisher,   stored: true
      text :dc_identifier,  stored: true
      text :dc_rights,      stored: true
      text :dc_contributor, stored: true
      text :dc_coverage_t,  stored: true
      text :dc_coverage_s,  stored: true
      text :dc_date,        stored: true
      text :dc_source,      stored: true
      text :dc_subject,     stored: true
      text :dc_type,        stored: true
      text :dc_description, stored: true
      text :dc_creator,     stored: true
      text :dc_language,    stored: true
      text :dc_relation,    stored: true

      # Fields for Faceting, etc.
      string :format, stored: true do
        dc_type.first ? dc_type.first : ''
      end

      string :location_facet, multiple: true do
        dc_coverage_s
      end

      string :subject_facet, multiple: true do
        dc_subject
      end

      string :type_facet, multiple: true do
        dc_type
      end

      string :creator_facet, multiple: true do
        dc_creator
      end

      string :sort_title do
        dc_title.first.downcase.gsub(/^(an?|the)\b/, '')
      end

    end

  end

end