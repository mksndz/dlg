class BatchImport < ActiveRecord::Base

  belongs_to :batch
  belongs_to :user
  has_many :batch_items, dependent: :destroy

  def completed?
    !!completed_at
  end

end
