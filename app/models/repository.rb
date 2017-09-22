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

  def self.index_query_fields
    %w().freeze
  end

  def record_id
    slug
  end

  def display?
    public?
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
