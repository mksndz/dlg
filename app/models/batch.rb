class Batch < ActiveRecord::Base
  include IndexFilterable

  belongs_to :user
  has_many :batch_items, dependent: :destroy
  has_many :batch_imports, dependent: :destroy

  scope :committed,   -> { where('committed_at IS NOT NULL' ) }
  scope :pending,     -> { where('committed_at IS NULL' ) }

  validates_presence_of :user, :name

  def self.index_query_fields
    %w(user_id committed_at).freeze
  end

  def has_invalid_batch_items?
    batch_items.where(valid_item: false).exists?
  end

  def committed?
    !!committed_at
  end

  def pending?
    !!queued_for_commit_at and not committed_at
  end

  def commit
    self.committed_at = Time.now
    successes = []
    failures = []
    batch_items.each do |bi|
      i = bi.commit
      begin
        i.save
        Sunspot.commit
      rescue StandardError => e
        failures << { batch_item: bi.id, errors: e, slug: bi.slug }
      end
      if i.errors.empty?
        # item properly committed, save Item and BI ids
        successes << { batch_item: bi.id, item: i.id, slug: bi.slug }
      else
        # item did not properly get built, add errors to array with BI id
        failures << { batch_item: bi.id, errors: i.errors, slug: bi.slug }
      end
    end
    self.commit_results = { items: successes, errors: failures }
    self.save
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
    self.commit_results['items'].map do |r|
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

