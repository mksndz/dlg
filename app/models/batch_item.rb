class BatchItem < ActiveRecord::Base
  include Slugged
  include ItemTypeValidatable
  include Portable

  belongs_to :batch, counter_cache: true
  belongs_to :batch_import, counter_cache: true
  belongs_to :collection
  belongs_to :item
  has_one :repository, through: :collection

  after_save :lookup_coordinates

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
    portals = self.portals
    if item_id
      # replace existing
      self.item.update attributes
      self.item.portals = portals
      self.item
    else
      item = Item.new attributes
      item.portals = portals
      item
    end
  end

  def next
    self.batch.batch_items.where('id > ?', id).first
  end

  def previous
    self.batch.batch_items.where('id < ?', id).last
  end

  def lookup_coordinates

    with_coordinates = []

    dcterms_spatial.each do |spatial|

      coordinates_found = false

      m = Item.connection.select_all("
        SELECT DISTINCT * FROM (
          SELECT unnest(dcterms_spatial) spatial FROM items
        ) s WHERE spatial LIKE '#{spatial}%';
      ")

      if m.any?

        m.each do |v|

          if v['spatial'][0..-25] == spatial

            with_coordinates << v['spatial']
            coordinates_found = true

          end

        end

      end

      with_coordinates << spatial unless coordinates_found

      self.update_columns dcterms_spatial: with_coordinates

    end
  end

end