class Item < ActiveRecord::Base
  include Slugged
  include DcHelper
  include IndexFilterable
  include ItemTypeValidatable

  belongs_to :collection, counter_cache: true
  has_one :repository, through: :collection
  has_many :batch_items

  validates_uniqueness_of :slug, scope: :collection_id
  validates_presence_of :collection

  has_paper_trail

  searchable do

    # todo remove unnecessarily stored fields when indexing is ready, remembering to alter solr field names where applicable

    string :slug, stored: true

    string :record_id, stored: true

    # set empty proxy id field so sunspot knows about it
    # value is set prior to save
    # sunspot search will not work without this, but indexing will
    # see monkeypatch @ config/initializers/sunspot_indexer_id.rb
    string :sunspot_id, stored: true do
      ''
    end

    # use case?
    integer :collection_id do
      collection.id
    end

    # use case?
    integer :repository_id do
      repository.id
    end

    boolean :dpla
    boolean :public

    # multivalued to hold names of 'other collections'
    string :collection_name, stored: true, multiple: true do
      collection_titles
    end

    # todo this could be multivalued if the other collection is in another repo
    string :repository_name, stored: true do
      repository.title
    end

    string :thumbnail_url, stored: true do
      thumbnail_url
    end

    # DC Fields for Searching
    # *_display fields created via copyFields
    text :dc_identifier
    text :dc_right
    text :dc_relation
    text :dc_format
    text :dc_date
    text :dcterms_is_part_of
    text :dcterms_contributor
    text :dcterms_creator
    text :dcterms_description
    text :dcterms_extent
    text :dcterms_medium
    text :dcterms_identifier
    text :dcterms_language
    text :dcterms_spatial
    text :dcterms_publisher
    text :dcterms_access_right
    text :dcterms_rights_holder
    text :dcterms_subject
    text :dcterms_temporal
    text :dcterms_title
    text :dcterms_type
    text :dcterms_is_shown_at
    text :dcterms_provenance
    text :dcterms_license

    # required for Blacklight - a single valued format field
    # 'format' field name in solr is created from this via a copyField
    string :format do
      dc_format.first ? dc_format.first : ''
    end

    # Fields for Faceting, etc.
    string :sort_collection, stored: true do
      collection.title.downcase.gsub(/^(an?|the)\b/, '')
    end

    string :sort_title, stored: true do
      dcterms_title.first ? dcterms_title.first.downcase.gsub(/^(an?|the)\b/, '') : ''
    end

    string :sort_creator, stored: true do
      dcterms_creator.first ? dcterms_creator.first.downcase.gsub(/^(an?|the)\b/, '') : ''
    end

    time :created_at, stored: true, trie: true
    time :updated_at, stored: true, trie: true

    integer :sort_year, stored: true, trie: true do
      facet_years.first
    end

    integer :year_facet, multiple: true, stored: true, trie: true do
      facet_years
    end

  end

  def self.index_query_fields
    %w(collection_id public).freeze
  end

  def facet_years
    all_years = []
    dc_date.each do |date|
      all_years << date.scan(/[0-2][0-9][0-9][0-9]/)
    end
    all_years.flatten.uniq
  end

  def collection_titles
    (other_collection_titles << collection.title).reverse
  end

  def record_id
    "#{self.repository.slug}_#{self.collection.slug}_#{self.slug}"
  end

  def thumbnail_url
    "http://dlg.galileo.usg.edu/#{repository.slug}/#{collection.slug}/do-th:#{slug}"
  end

  def title
    dcterms_title.first || 'No Title'
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

  private

  def other_collection_titles
    Collection.find(other_collections).map(&:title)
  end

end

