class Repository < ActiveRecord::Base
  include Slugged
  include Portable
  include IndexFilterable

  has_many :collections, dependent: :destroy
  has_many :items, through: :collections
  has_and_belongs_to_many :users

  scope :updated_since, lambda { |since| where('updated_at >= ?', since) }

  validates_presence_of :title
  validate :coordinates_format

  after_update :reindex_display_values_for_children

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

    string :portals, multiple: true do
      portal_codes
    end

    string :portal_names, stored: true, multiple: true do
      portal_names
    end

    string :title, stored: true
    string :short_description, stored: true
    string :description, stored: true
    string :thumbnail_path, stored: true

    text :title
    text :short_description
    text :description

    string :coordinates, stored: true

    boolean :teaser
    boolean :public
    boolean :dpla
    boolean :display do
      display?
    end

  end

  def self.index_query_fields
    %w().freeze
  end

  def record_id
    slug
  end

  def display?
    public
  end

  private

  def reindex_display_values_for_children
    Resque.enqueue(Reindexer, 'Collection', collections.map(&:id))
    Resque.enqueue(Reindexer, 'Item', items.map(&:id))
    true
  end

  def coordinates_format
    if !coordinates || coordinates.empty?
      errors.add(:coordinates, I18n.t('activerecord.errors.messages.repository.blank'))
      return false
    end
    lat, lon = coordinates.split(', ')
    begin
      lat = Float(lat)
      lon = Float(lon)
      if lat < -90 || lat > 90 || lon < -180 || lon > 180
        errors.add(:coordinates, I18n.t('activerecord.errors.messages.repository.coordinates'))
        return false
      end
    rescue TypeError, ArgumentError
      errors.add(:coordinates, I18n.t('activerecord.errors.messages.repository.coordinates'))
      return false
    end
  end

end
