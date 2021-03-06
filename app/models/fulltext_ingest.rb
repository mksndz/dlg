# frozen_string_literal: true

# represent an instance of an ingest of fulltext data
class FulltextIngest < ActiveRecord::Base
  belongs_to :user
  validates :title, presence: true
  validates :title, uniqueness: true
  validates :file, presence: true
  mount_uploader :file, FulltextUploader

  def undo
    begin
      Item.where('record_id IN (?)', modified_record_ids).update_all(
        fulltext: nil, updated_at: Time.zone.now
      )
    rescue StandardError => e
      results['status'] = 'undo failed'
      results['message'] = e.message
      return false
    end
    self.undone_at = Time.zone.now
    save
  end

  def success?
    results['status'] == 'success'
  end

  def succeeded
    results['files']['succeeded']
  end

  def failed?
    results && results['status'] == 'failed'
  end

  def failed
    results['files']['failed']
  end

  def partial_failure?
    results['status'] == 'partial failure'
  end

  def processed_files
    return nil unless results.key? 'files'

    results['files']
  end

  def modified_record_ids
    Item.where(id: succeeded).pluck(:record_id)
  end
end
