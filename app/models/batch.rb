class Batch < ActiveRecord::Base

  belongs_to :user
  has_many :batch_items, dependent: :destroy

  scope :committed, -> { where('committed_at IS NOT NULL' ) }
  scope :pending, -> { where('committed_at IS NULL' ) }

  validates_presence_of :user, :name

  searchable do

    text :name
    text :notes

    integer :user_id

    time :committed_at
    time :updated_at
    time :created_at

  end

  def committed?
    !!committed_at
  end

  def commit
    self.committed_at = Time.now
    successes = []
    failures = []
    batch_items.each do |bi|
      i = bi.commit
      i.save
      if i.errors.empty?
        # item properly committed, save Item  and BI ids
        successes << { batch_item: bi.id, item: i.id, slug: bi.slug }
      else
        # item did not properly get built, add errors to array with BI id
        failures << { batch_item: bi.id, errors: i.errors, slug: bi.slug }
      end
    end
    self.commit_results = { items: successes, errors: failures }
    self.save
  end

end

