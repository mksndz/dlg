class Item < ActiveRecord::Base
  # include SolrIndexing
  include Slugged

  belongs_to :collection
  has_one :repository, through: :collection

  validates_uniqueness_of :slug, scope: :collection_id

  searchable do

    string :slug, stored: true

    # set empty proxy id field so sunspot knows about it
    # value is set prior to save
    # sunspot search will not work without this, but indexing will
    # see monkeypatch @ config/initializers/sunspot_indexer_id.rb
    string :sunspot_id, stored: true do
      ''
    end

    integer :collection_id, references: Collection
    integer :repository_id, references: Repository

    boolean :dpla
    boolean :public

    string :in_collection, stored: true do
      collection ? collection.display_title : ''
    end

    # DC Fields for Searching
    # *_display fields created via copyFields
    text :dc_title
    text :dc_format
    text :dc_publisher
    text :dc_identifier
    text :dc_right
    text :dc_contributor
    text :dc_coverage_temporal
    text :dc_coverage_spatial
    text :dc_date
    text :dc_source
    text :dc_subject
    text :dc_type
    text :dc_description
    text :dc_creator
    text :dc_language
    text :dc_relation

    # Fields for Faceting, etc.
    string :format, stored: true do
      dc_type.first ? dc_type.first : ''
    end

    string :sort_title do
      dc_title.first ? dc_title.first.downcase.gsub(/^(an?|the)\b/, '') : ''
    end

  end

  def title
    dc_title.first
  end

  def to_xml(options = {})
    default_options = {
        dasherize: false,
        # fields to not include
        except: [
            :collection_id,
            :created_at,
            :updated_at
        ],
        include: {
            collection: {
                only: [
                    :slug
                ]
            }
        }
    }
    super(options.merge!(default_options))
  end
end

