class Collection < ActiveRecord::Base
  include Slugged
  include IndexFilterable

  has_many :items, dependent: :destroy
  has_many :public_items, -> { where public: true }, class_name: 'Item'
  has_many :dpla_items, -> { where dpla: true }, class_name: 'Item'
  belongs_to :repository, counter_cache: true
  has_and_belongs_to_many :subjects
  has_and_belongs_to_many :time_periods
  has_and_belongs_to_many :users

  validates_presence_of :repository
  validates_presence_of :display_title
  validates_uniqueness_of :slug, scope: :repository_id

  def self.index_query_fields
    %w(repository_id public).freeze
  end

  def title
    display_title || 'No Title'
  end

  # allow Items to delegate collection_title
  alias_method :collection_title, :title

  searchable do

    string :slug, stored: true

    string :record_id, stored: true

    # set empty proxy id field so sunspot knows about it
    # value is set prior to save
    # sunspot search will not work without this, but indexing will
    # see monkeypatch @ config/initializers/sunspot_indexer_id.rb
    string :sunspot_id, stored: true do
      ''
    end

    integer :repository_id, references: Repository

    boolean :public

    string :repository_name, stored: true do
      repository ? repository.title : ''
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

    # Fields for Faceting, etc.
    string :format, stored: true do
      dcterms_type.first ? dcterms_type.first : ''
    end

    string :sort_title do
      dcterms_title.first ? dcterms_title.first.downcase.gsub(/^(an?|the)\b/, '') : ''
    end

  end

  def record_id
    "#{repository.slug}_#{self.slug}"
  end

  def to_xml(options = {})
    default_options = {
        dasherize: false,
        # fields to not include
        except: [
            :repository_id,
            :created_at,
            :updated_at,
            :other_collections
        ]
    }

    if options[:show_repository]
      default_options[:include] = [ repository: { only: [ :slug ] } ]
    end

    super(options.merge!(default_options))
  end
end

