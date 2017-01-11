class BatchItem < ActiveRecord::Base
  include Slugged
  include ItemTypeValidatable
  include Portable

  belongs_to :batch, counter_cache: true
  belongs_to :batch_import, counter_cache: true
  belongs_to :collection
  belongs_to :item
  has_one :repository, through: :collection

  def title
    dcterms_title.first
  end

  def has_thumbnail?
    has_thumbnail
  end

  def other_collection_titles
    Collection.find(other_collections.reject{ |c| c.nil? }).map(&:title)
  end

  def commit
    scrub_attributes = %w(id created_at updated_at batch_id batch_import_id)
    attributes = self.attributes.except(*scrub_attributes)
    item_id = attributes.delete('item_id')
    if item_id
      # replace existing
      self.item.update attributes
      self.item
    else
      Item.new attributes
    end
  end

  def next
    self.batch.batch_items.where('id > ?', id).first
  end

  def previous
    self.batch.batch_items.where('id < ?', id).last
  end

end