class Collection < ActiveRecord::Base
  include Slugged
  include IndexFilterable
  include GeospatialIndexable
  include Portable
  include CollectionValidations
  include Provenanced

  has_many :items, dependent: :destroy
  has_many :public_items, -> { where public: true }, class_name: 'Item'
  has_many :dpla_items, -> { where dpla: true }, class_name: 'Item'
  has_many :batch_items, dependent: :nullify
  belongs_to :repository, counter_cache: true
  has_and_belongs_to_many :subjects
  has_and_belongs_to_many :time_periods
  has_and_belongs_to_many :users

  scope :updated_since, lambda { |since| where('updated_at >= ?', since) }

  validates_presence_of :repository

  before_destroy :clear_from_other_collections
  before_save :update_record_id
  after_update :reindex_children

  def self.index_query_fields
    %w[repository_id public].freeze
  end

  def title
    display_title || 'No Title'
  end

  # allow Items to delegate collection_title
  alias_method :collection_title, :title

  searchable do

    string :class_name, stored: true do
      self.class
    end

    string :slug, stored: true
    string :record_id, stored: true

    # set empty proxy id field so sunspot knows about it
    # value is set prior to save
    # sunspot search will not work without this, but indexing will
    # see monkeypatch @ config/initializers/sunspot_indexer_id.rb
    string :sunspot_id, stored: true do
      ''
    end

    integer :repository_id do
      repository.id
    end

    string :repository_slug do
      repository.slug
    end

    string :thumbnail, stored: true do
      # TODO: use brad's thumb links for now
      "http://dlg.galileo.usg.edu/do-th:#{repository.slug}"
    end

    boolean :public
    boolean :display do
      display?
    end

    string :public, stored: true do
      public ? 'Yes' : 'No'
    end

    string :display, stored: true do
      display? ? 'Yes' : 'No'
    end

    string :repository_name, stored: true, multiple: true do
      repository_titles
    end

    string :portal_names, stored: true, multiple: true do
      portal_names
    end

    string :portals, stored: true, multiple: true do
      portal_codes
    end

    string :portal_names, stored: true, multiple: true do
      portal_names
    end

    string :display_title, stored: true, as: 'display_title_display'
    string :short_description, stored: true, as: 'short_description_display'

    # *_display (not indexed, stored, multivalued)
    string :legacy_dcterms_provenance,      as: 'dcterms_provenance_display',             multiple: true
    string :dcterms_type,                   as: 'dcterms_type_display',                   multiple: true
    string :dcterms_spatial,                as: 'dcterms_spatial_display',                multiple: true
    string :dcterms_title,                  as: 'dcterms_title_display',                  multiple: true
    string :dcterms_creator,                as: 'dcterms_creator_display',                multiple: true
    string :dcterms_contributor,            as: 'dcterms_contributor_display',            multiple: true
    string :dcterms_subject,                as: 'dcterms_subject_display',                multiple: true
    string :dcterms_description,            as: 'dcterms_description_display',            multiple: true
    string :dcterms_publisher,              as: 'dcterms_publisher_display',              multiple: true
    string :edm_is_shown_at,                as: 'edm_is_shown_at_display',                multiple: true
    string :edm_is_shown_by,                as: 'edm_is_shown_by_display',                multiple: true
    string :dcterms_identifier,             as: 'dcterms_identifier_display',             multiple: true
    string :dc_date,                        as: 'dc_date_display',                        multiple: true
    string :dcterms_temporal,               as: 'dcterms_temporal_display',               multiple: true
    string :dc_format,                      as: 'dc_format_display',                      multiple: true
    string :dcterms_is_part_of,             as: 'dcterms_is_part_of_display',             multiple: true
    string :dc_right,                       as: 'dc_right_display',                       multiple: true
    string :dcterms_rights_holder,          as: 'dcterms_rights_holder_display',          multiple: true
    string :dcterms_bibliographic_citation, as: 'dcterms_bibliographic_citation_display', multiple: true
    string :dlg_local_right,                as: 'dlg_local_right_display',                multiple: true
    string :dlg_subject_personal,           as: 'dlg_subject_personal_display',           multiple: true
    string :dc_relation,                    as: 'dc_relation_display',                    multiple: true
    string :dcterms_medium,                 as: 'dcterms_medium_display',                 multiple: true
    string :dcterms_extent,                 as: 'dcterms_extent_display',                 multiple: true
    string :dcterms_language,               as: 'dcterms_language_display',               multiple: true

    # special collection-only fields
    string :collection_provenance_facet, multiple: true, as: 'collection_provenance_facet' do
      holding_institution_names
    end
    string :collection_type_facet, multiple: true, as: 'collection_type_facet' do
      dcterms_type
    end
    string :collection_spatial_facet, multiple: true, as: 'collection_spatial_facet' do
      dcterms_spatial
    end

    # just stored content
    string :partner_homepage_url,   as: 'partner_homepage_url_display'
    string :homepage_text,          as: 'homepage_text_display'

    # Primary Search Fields (multivalued, indexed, stemming/tokenized)
    text :dc_date
    text :dcterms_title
    text :dcterms_creator
    text :dcterms_contributor
    text :dcterms_subject
    text :dcterms_description
    text :dcterms_publisher
    text :dcterms_temporal
    text :dcterms_spatial
    text :dcterms_is_part_of
    text :edm_is_shown_at
    text :edm_is_shown_by
    text :dcterms_identifier
    text :dcterms_rights_holder
    text :dlg_subject_personal
    text :dcterms_provenance

    string :title, as: 'title' do
      dcterms_title.first ? dcterms_title.first : slug
    end

    # required for Blacklight - a single valued format field
    string :format, as: 'format' do
      dc_format.first ? dc_format.first : ''
    end

    # sort fields

    string :title_sort, as: 'title_sort' do
      dcterms_title.first ? dcterms_title.first.downcase.gsub(/^(an?|the)\b/, '') : ''
    end

    string :creator_sort, as: 'creator_sort' do
      dcterms_creator.first ? dcterms_creator.first.downcase.gsub(/^(an?|the)\b/, '') : ''
    end

    integer :year, as: 'year', trie: true do
      DateIndexer.new.get_sort_date(dc_date)
    end

    # facet fields
    integer :year_facet, multiple: true, trie: true, as: 'year_facet' do
      DateIndexer.new.get_valid_years_for(dc_date, self)
    end
    string :counties, as: 'counties_facet', multiple: true

    # datetimes
    time :created_at, stored: true, trie: true
    time :updated_at, stored: true, trie: true

    # spatial stuff
    string :coordinates, as: 'coordinates', multiple: true
    string :geojson, as: 'geojson', multiple: true
    string :placename, as: 'placename', multiple: true

    # time periods
    string :time_periods, multiple: true, stored: true do
      time_periods.map(&:name)
    end

    # subjects
    string :subjects, multiple: true, stored: true do
      subjects.map(&:name)
    end

    string :image, stored: true do
      holding_institution_image
    end
  end

  def holding_institution_image
    holding_institutions.first.image.url if holding_institutions.any?
  end

  def repository_title
    repository.title
  end

  def display?
    repository.public && public
  end

  def to_xml(options = {})
    default_options = {
      dasherize: false,
      except: %i[id repository_id created_at updated_at other_repositories
                 items_count date_range]
    }
    if options[:show_repository]
      default_options[:include] = [repository: { only: [:slug] }]
    end
    if options[:show_provenance]
      default_options[:methods] ||= []
      default_options[:methods] << :dcterms_provenance
    end
    super(options.merge!(default_options))
  end

  def as_json(options = {})
    new_options = {
      except: :legacy_dcterms_provenance,
      methods: :dcterms_provenance
    }
    super(options.merge!(new_options))
  end

  def other_repository_titles
    Repository.find(other_repositories).map(&:title).uniq
  end

  def repository_titles
    (other_repository_titles << repository.title).reverse.uniq
  end

  def parent
    repository
  end

  private

  def reindex_children
    if slug_changed? || display_title_changed? || repository_id_changed?
      resave_children if repository_id_changed? || slug_changed?
      resaved = true
    end
    if !resaved && items.any? && public_changed?
      Resque.enqueue(Reindexer, 'Item', items.map(&:id))
    end
    true
  end

  def resave_children
    Resque.enqueue(Resaver, items.map(&:id))
  end

  def update_record_id
    self.record_id = "#{repository.slug}_#{slug}"
  end

  def clear_from_other_collections
    is = Item.where "#{id} = ANY (other_collections)"
    is.each do |i|
      i.other_collections = i.other_collections - [id]
      i.save(validate: false)
    end
  end

end

