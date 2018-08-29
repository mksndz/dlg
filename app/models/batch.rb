class Batch < ActiveRecord::Base
  include IndexFilterable

  belongs_to :user
  has_many :batch_items, dependent: :destroy
  has_many :batch_imports, dependent: :destroy

  default_scope { order({ committed_at: :desc }, created_at: :asc) }
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
    logger = Logger.new('./log/batch_commit.log')
    results = []
    # Special DbTransaction class used here to mitigate huge memory usage when
    # committing large batches. Removes and holds Item callbacks in until
    # transaction completes, then runs them. This prevents AR from holding the
    # models in memory until the transaction completes.
    DbTransaction.new(Item).perform do
      batch_items.in_batches(of: 200).each_record do |bi|
        retried = false
        begin
          results << convert_to_item(bi)
        rescue Net::ReadTimeout => e
          raise(StandardError, "Network Issue saving BatchItem #{bi.id}") if retried
          sleep 120
          retried = true
          retry
        rescue ActiveRecord::RecordInvalid => e
          msg = "BatchItem #{bi.id} failed validations: #{e.message}"
          logger.error msg
          raise StandardError, msg
        rescue StandardError => e
          msg = "BatchItem #{bi.id} failed: #{e.message}"
          logger.error msg
          raise StandardError, msg
        end
      end
    end
    self.job_message = nil # clear job message if job succeeds
    self.committed_at = Time.now
    Sunspot.commit
    self.commit_results = { items: results }
    save
  end

  # create a new batch and populate with batch_items that are copied from the
  # current state of the items that were created when the batch was committed
  # todo only for committed batches? consider
  def recreate
    batch = Batch.new
    batch.name = "RECREATED #{name}"
    item_ids = created_item_ids
    batch.batch_items << batch_items_from_items(item_ids)
    batch
  end

  def inpermissable_items?(user)
    return true unless user
    return false if user.super?
    included_collection_ids.each do |collection_id|
      next if user.collection_ids.include? collection_id
      collection = Collection.find collection_id
      repository_id = collection.repository_id
      next if user.repositories.include? repository_id
      return true
    end
    false
  end

  private

  def convert_to_item(batch_item)
    i = batch_item.commit
    i.batch_items << batch_item
    item_updated = i.persisted?
    i.save!
    {
      batch_item: batch_item.id,
      item: i.id,
      slug: batch_item.slug,
      item_updated: item_updated
    }
  end

  def created_item_ids
    commit_results['items'].map do |r|
      r['item']
    end
  end

  def batch_items_from_items(item_ids)
    Item.find(item_ids).map do |item|
      scrub_attributes = %w[created_at updated_at]
      attributes = item.attributes.except(*scrub_attributes)
      item_id = attributes.delete('id')
      batch_item = BatchItem.new attributes
      batch_item.item_id = item_id
      batch_item.portals = item.portals
      batch_item.holding_institutions = item.holding_institutions
      batch_item
    end
  end

  def included_collection_ids
    batch_items.map(&:collection_id).uniq
  end

end

