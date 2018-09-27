# represent a Repository
class Repository < ActiveRecord::Base
  include Slugged
  include Portable
  include IndexFilterable

  has_and_belongs_to_many :holding_institutions
  has_many :collections, dependent: :destroy
  has_many :items, through: :collections
  has_and_belongs_to_many :users

  scope :updated_since, lambda { |since| where('updated_at >= ?', since) }

  after_update :reindex_child_values

  validates_presence_of :title
  validates_uniqueness_of :slug

  def self.index_query_fields
    %w[].freeze
  end

  def record_id
    slug
  end

  def display?
    public?
  end

  private

  def reindex_child_values
    if slug_changed? || title_changed? || public_changed?
      queue_reindex_collections
      queue_reindex_items
    end
    true
  end

  def queue_reindex_collections
    Resque.enqueue(Reindexer, 'Collection', collections.map(&:id)) if collections.any?
  end

  def queue_reindex_items
    Resque.enqueue(Reindexer, 'Item', items.map(&:id)) if items.any?
  end

end
