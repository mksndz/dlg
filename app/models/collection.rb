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

  before_destroy :clear_from_other_collections

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

    integer :repository_id do
      repository.id
    end

    boolean :public

    # string :collection_name, stored: true, multiple: true do
    #   collection_titles
    # end

    string :repository_name, stored: true, multiple: true do
      repository_titles
    end

    # string :thumbnail_url, as: 'thumbnail_url' do
    #   thumbnail_url
    # end

    # *_display (not indexed, stored, multivalued)
    string :dcterms_provenance,             as: 'dcterms_provenance_display',             multiple: true
    string :dcterms_title,                  as: 'dcterms_title_display',                  multiple: true
    string :dcterms_creator,                as: 'dcterms_creator_display',                multiple: true
    string :dcterms_contributor,            as: 'dcterms_contributor_display',            multiple: true
    string :dcterms_subject,                as: 'dcterms_subject_display',                multiple: true
    string :dcterms_description,            as: 'dcterms_description_display',            multiple: true
    string :dcterms_publisher,              as: 'dcterms_publisher_display',              multiple: true
    string :dcterms_is_shown_at,            as: 'dcterms_is_shown_at_display',            multiple: true
    string :dc_date,                        as: 'dc_date_display',                        multiple: true
    string :dcterms_temporal,               as: 'dcterms_temporal_display',               multiple: true
    string :dcterms_spatial,                as: 'dcterms_spatial_display',                multiple: true
    string :dc_format,                      as: 'dc_format_display',                      multiple: true
    string :dcterms_is_part_of,             as: 'dcterms_is_part_of_display',             multiple: true
    string :dc_right,                       as: 'dc_right_display',                       multiple: true
    string :dcterms_rights_holder,          as: 'dcterms_rights_holder_display',          multiple: true
    string :dcterms_bibliographic_citation, as: 'dcterms_bibliographic_citation_display', multiple: true
    string :dlg_local_right,                as: 'dlg_local_right_display',                multiple: true
    string :dc_relation,                    as: 'dc_relation_display',                    multiple: true
    string :dcterms_type,                   as: 'dcterms_type_display',                   multiple: true
    string :dcterms_medium,                 as: 'dcterms_medium_display',                 multiple: true
    string :dcterms_extent,                 as: 'dcterms_extent_display',                 multiple: true
    string :dcterms_language,               as: 'dcterms_language_display',               multiple: true

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
    text :dcterms_is_shown_at

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

    # datetimes
    time :created_at, stored: true, trie: true
    time :updated_at, stored: true, trie: true

    # spatial coordinates
    # string :coordinates, as: 'coordinates' do
    #   coordinates
    # end
    #
    # # geojson
    # string :geojson, as: 'geojson'
    #
    # # spatial placename
    # string :placename, as: 'placename'

    # time periods
    string :time_periods, multiple: true do
      time_periods.map(&:name)
    end

    # subjects
    string :subjects, multiple: true do
      subjects.map(&:name)
    end

  end

  def record_id
    "#{repository.slug}_#{self.slug}"
  end

  def repository_title
    repository.title
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

  def other_repository_titles
    Repository.find(other_repositories).map(&:title)
  end

  def repository_titles
    (other_repository_titles << repository.title).reverse
  end

  private

  def clear_from_other_collections
    is = Item.where "#{self.id} = ANY (other_collections)"
    is.each do |i|
      i.other_collections = i.other_collections - [self.id]
      i.save(validate: false)
    end
  end

end

