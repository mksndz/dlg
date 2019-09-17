# BatchItem model describes relations to Batch and Item records, as well as the
# BatchItem commit process
class BatchItem < ActiveRecord::Base
  include Slugged
  include ItemTypeValidatable
  include Portable
  include ItemTypeCleaner
  include Provenanced
  include MetaGeocodable

  belongs_to :batch, counter_cache: true
  belongs_to :batch_import, counter_cache: true
  belongs_to :collection
  belongs_to :item
  has_one :repository, through: :collection

  COMMIT_SCRUB_ATTRIBUTES = %w[
    id
    created_at
    updated_at
    batch_id
    batch_import_id
  ].freeze

  def title
    dcterms_title.first
  end

  def thumbnail?
    has_thumbnail
  end

  def other_collection_titles
    Collection.find(other_collections.reject(&:nil?)).map(&:title)
  end

  def commit
    attributes = self.attributes.except(*COMMIT_SCRUB_ATTRIBUTES)
    item_id = attributes.delete('item_id')
    if item_id
      remove_existing_from_index(item) if batch_import.try(:match_on_id?) # de-index object since we are changing primary id
      item.update_attributes! attributes
    else
      self.item = Item.new attributes
    end
    item.portals = portals
    item.holding_institutions = holding_institutions
    item
  end

  def next
    batch.batch_items.where('id > ?', id).first
  end

  def previous
    batch.batch_items.where('id < ?', id).last
  end

  private

  def remove_existing_from_index(item)
    Sunspot.remove item
  end
end