class Batch < ActiveRecord::Base
  include IndexFilterable

  belongs_to :user
  has_many :batch_items, dependent: :destroy
  has_many :batch_imports, dependent: :destroy

  scope :committed,   -> { where('committed_at IS NOT NULL') }
  scope :pending,     -> { where('committed_at IS NULL') }

  validates_presence_of :user, :name

  def self.index_query_fields
    %w(user_id committed_at).freeze
  end

  def invalid_batch_items?
    batch_items.where(valid_item: false).exists?
  end

  def committed?
    committed_at
  end

  def pending?
    queued_for_commit_at && !committed_at
  end

  def commit
    self.committed_at = Time.now
    successes = []
    failures = []
    batch_items.each do |bi|
      if bi.invalid?
        # if bi is invalid (it shouldn't be), dont bother trying to save the item
        failures << { batch_item: bi.id, errors: bi.errors, slug: bi.slug }
      else
        i = bi.commit
        i.batch_items << bi
        item_updated = i.persisted?
        if i.save
          # item properly committed, save Item and BI ids
          successes << { batch_item: bi.id, item: i.id, slug: bi.slug, item_updated: item_updated }
        else
          # item did not properly save, add errors to array with BI id
          # this should only obtain on DB error or as a result of validation
          # discrepancies between item and batchitem
          failures << { batch_item: bi.id, errors: i.errors, slug: bi.slug }
        end
      end

    end
    Sunspot.commit
    self.commit_results = { items: successes, errors: failures }
    save
  end

  # create a new batch and populate with batch_items that are copied from the
  # current state of the items that were created when the batch was committed
  # todo only for committed batches? consider
  def recreate
    batch = Batch.new
    # batch.user = current_user
    batch.name = "RECREATED #{self.name}"
    item_ids = get_created_item_ids
    batch.batch_items << batch_items_from_items(item_ids)
    batch
  end

  private

  def get_created_item_ids
    commit_results['items'].map do |r|
      r['item']
    end
  end

  def batch_items_from_items(item_ids)
    Item.find(item_ids).map do |item|
      scrub_attributes = %w(created_at updated_at)
      attributes = item.attributes.except(*scrub_attributes)
      item_id = attributes.delete('id')
      batch_item = BatchItem.new attributes
      batch_item.item_id = item_id
      batch_item
    end
  end

end

