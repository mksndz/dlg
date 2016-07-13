class Item < ActiveRecord::Base
  include ApplicationHelper
  include Slugged
  include MetadataHelper
  include IndexFilterable
  include ItemTypeValidatable

  belongs_to :collection, counter_cache: true
  has_one :repository, through: :collection
  has_many :batch_items

  validates_uniqueness_of :slug, scope: :collection_id
  validates_presence_of :collection

  has_paper_trail class_name: "ItemVersion"

  # after_save :check_for_thumbnail

  searchable do

    # todo remove unnecessarily stored fields when indexing is ready, remembering to alter solr field names where applicable

    string :slug, stored: true
    string :record_id, stored: true

    # set empty proxy id field so sunspot knows about it
    # value is set prior to save
    # sunspot search will not work without this, but indexing will
    # see monkeypatch @ config/initializers/sunspot_indexer_id.rb
    string :sunspot_id, stored: true do
      ""
    end

    integer :collection_id do
      collection.id
    end

    integer :repository_id do
      repository.id
    end

    boolean :dpla
    boolean :public

    string :collection_name, stored: true, multiple: true do
      collection_titles
    end

    string :repository_name, stored: true, multiple: true do
      repository_titles
    end

    string :thumbnail_url, as: 'thumbnail_url' do
      # if has_thumbnail?
      #   thumbnail_url
      # else
      #   'no-thumb.png'
      # end
      thumbnail_url
    end

    # *_display (not indexed, stored, multivalued)
    string :dlg_local_right,        as: 'dlg_local_right_display',        multiple: true
    string :dc_date,                as: 'dc_date_display',                multiple: true
    string :dc_format,              as: 'dc_format_display',              multiple: true
    string :dc_relation,            as: 'dc_relation_display',            multiple: true
    string :dc_right,               as: 'dc_right_display',               multiple: true
    string :dcterms_contributor,    as: 'dcterms_contributor_display',    multiple: true
    string :dcterms_creator,        as: 'dcterms_creator_display',        multiple: true
    string :dcterms_description,    as: 'dcterms_description_display',    multiple: true
    string :dcterms_extent,         as: 'dcterms_extent_display',         multiple: true
    string :dcterms_identifier,     as: 'dcterms_identifier_display',     multiple: true
    string :dcterms_is_part_of,     as: 'dcterms_is_part_of_display',     multiple: true
    string :dcterms_is_shown_at,    as: 'dcterms_is_shown_at_display',    multiple: true
    string :dcterms_language,       as: 'dcterms_language_display',       multiple: true
    string :dcterms_medium,         as: 'dcterms_medium_display',         multiple: true
    string :dcterms_provenance,     as: 'dcterms_provenance_display',     multiple: true
    string :dcterms_publisher,      as: 'dcterms_publisher_display',      multiple: true
    string :dcterms_rights_holder,  as: 'dcterms_rights_holder_display',  multiple: true
    string :dcterms_subject,        as: 'dcterms_subject_display',        multiple: true
    string :dcterms_spatial,        as: 'dcterms_spatial_display',        multiple: true
    string :dcterms_temporal,       as: 'dcterms_temporal_display',       multiple: true
    string :dcterms_title,          as: 'dcterms_title_display',          multiple: true
    string :dcterms_type,           as: 'dcterms_type_display',           multiple: true

    # Primary Search Fields (multivalued, indexed)
    text :dcterms_title
    text :dcterms_description
    text :dcterms_subject
    text :dcterms_spatial
    text :dcterms_publisher
    text :dcterms_contributor
    text :dcterms_creator

    string :title, as: 'title' do
      dcterms_title.first ? dcterms_title.first : slug
    end

    # required for Blacklight - a single valued format field
    string :format, as: 'format' do
      dc_format.first ? dc_format.first : ''
    end

    # sort fields
    string :collection_sort, as: 'collection_sort' do
      collection.title.downcase.gsub(/^(an?|the)\b/, '')
    end

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
    string :coordinates, as: 'coordinates' do
      coordinates
    end

    # geojson
    string :geojson, as: 'geojson'

    # spatial placename
    string :placename, as: 'placename'

  end

  def self.index_query_fields
    %w(collection_id public valid_item).freeze
  end

  def has_thumbnail?
    has_thumbnail
  end

  def geojson
    %|{"type":"Feature","geometry":{"type":"Point","coordinates":[#{coordinates(true)}]},"properties":{"placename":"#{placename}"}}|
  end
  
  def placename
    return 'No Location Information Available' unless dcterms_spatial.first
    placename = dcterms_spatial.first.gsub(coordinates_regex, '')
    return placename.chop.chop if element_has_coordinates dcterms_spatial.first
    placename
  end

  # return first set of discovered coordinates, or a silly spot if none found
  # todo: figure out a way to not index a location for items with no coordinates
  def coordinates(alt_format = false)
    if alt_format
      return '-80.394617, 31.066399' unless has_coordinates?
      dcterms_spatial.each do |el|
        return "#{longitude(el)}, #{latitude(el)}" if element_has_coordinates el
      end
    else
      return '31.066399, -80.394617' unless has_coordinates?
      dcterms_spatial.each do |el|
        return "#{latitude(el)}, #{longitude(el)}" if element_has_coordinates el
      end
    end
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

  def repository_titles
    (other_repository_titles << repository.title).reverse
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

  def has_coordinates?
    dcterms_spatial.each do |s|
      return true if element_has_coordinates s
    end
    false
  end

  private

  def latitude(el)
    el.match(coordinates_regex)[1]
  end

  def longitude(el)
    el.match(coordinates_regex)[2]
  end

  def element_has_coordinates(e)
    coordinates_regex === e
  end

  def coordinates_regex
    /(-?\d+\.\d+), (-?\d+\.\d+)/
  end

  def other_collection_titles
    Collection.find(other_collections).map(&:title)
  end

  def other_repository_titles
    Collection.find(other_collections).map(&:repository_title)
  end

  def check_for_thumbnail
    update_column(:has_thumbnail, valid_url?(thumbnail_url) )
    true
  end

  # def date_facet
  #
  #   # check if dc_date contains a well-formatted date range
  #   dc_date.each do |date|
  #
  #     if date.scan(/\//).size == 1
  #
  #       # we likely have a date range here
  #       # try and get two dates, ISO style
  #       iso_dates = date.scan(/[0-2][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)
  #       if iso_dates.size == 2
  #
  #         # we have a likely date range!
  #         # so now we want to get all years in between....
  #         iso_dates.map { |d| Date.strptime(s, "%Y-%m-%d") }.sort
  #
  #
  #       end
  #     end
  #   end
  #
  # end

end

