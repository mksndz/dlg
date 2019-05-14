# frozen_string_literal: true

# represent an instance of an ingest of fulltext data
class PageIngest < ActiveRecord::Base
  belongs_to :user
  validates :title, presence: true
  validates :title, uniqueness: true
  mount_uploader :file, PageJsonUploader

  def results
    results_json
  end

  def success?
    results_json['status'] == 'success'
  end

  def succeeded
    results_json['added']
  end

  def failed
    results_json['errors']
  end

  def failed?
    results_json['status'] == 'failed'
  end

  def partial_failure?
    results_json['status'] == 'partial failure'
  end

end
