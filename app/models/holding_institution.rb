# represents a Holding Institution (dcterms_provenance value)
class HoldingInstitution < ActiveRecord::Base
  include IndexFilterable

  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :collections
  has_and_belongs_to_many :items
  has_and_belongs_to_many :batch_items
  has_many :projects

  mount_uploader :image, ImageUploader

  before_destroy :confirm_unassigned
  after_update :reindex_child_values

  validates_presence_of :display_name, :institution_type
  validates_uniqueness_of :display_name
  validate :coordinates_format

  def self.index_query_fields
    %w[institution_type]
  end

  def portal_names
    repositories.collect(&:portals).flatten.uniq.collect(&:name)
  end

  def confirm_unassigned
    return true if collections.empty? && items.empty?

    raise HoldingInstitutionInUseError, "Cannot delete Holding Institution as it remains assigned to #{items.length} Items and #{collections.length} Collections"
  end

  def coordinates_format
    return true if !coordinates || coordinates.empty?

    lat, lon = coordinates.split(', ')
    begin
      lat = Float(lat)
      lon = Float(lon)
      if lat < -90 || lat > 90 || lon < -180 || lon > 180
        errors.add(:coordinates, I18n.t('activerecord.errors.messages.holding_institution.coordinates'))
        return false
      end
    rescue TypeError, ArgumentError
      errors.add(:coordinates, I18n.t('activerecord.errors.messages.holding_institution.coordinates'))
      return false
    end
  end

  def reindex_child_values
    collection_queued = false
    if display_name_changed?
      queue_reindex_collections
      queue_reindex_items
      collection_queued = true
    end
    queue_reindex_collections if image_changed? && !collection_queued
    true
  end

  def queue_reindex_collections
    Resque.enqueue(Reindexer, 'Collection', collections.map(&:id)) if collections.any?
  end

  def queue_reindex_items
    Resque.enqueue(Reindexer, 'Item', items.map(&:id)) if items.any?
  end
end
