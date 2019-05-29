class BatchImport < ActiveRecord::Base

  belongs_to :batch
  belongs_to :user
  has_many :batch_items, dependent: :destroy

  SEARCH_RESULT_SOURCE = 'search query'.freeze

  def completed?
    !completed_at.nil?
  end

  # TODO: decorator method
  def from_search_result?
    format == SEARCH_RESULT_SOURCE
  end

end
