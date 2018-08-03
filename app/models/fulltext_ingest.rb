# frozen_string_literal: true

# represent an instance of an ingest of fulltext data
class FulltextIngest < ActiveRecord::Base

  belongs_to :user

  def undo
    Item.update_all(
      { fulltext: nil, updated_at: Date.today },
      'record_id in ?', modified_record_ids
    )
  end

  def success?
    results['status'] == 'success'
  end

  def failed?
    results['status'] == 'failed'
  end

  def partial_failure?
    results['status'] == 'partial failure'
  end

  def processed_files
    return nil unless results.key? 'files'
    results['files']
  end

  def modified_record_ids
    ids = []
    processed_files.each do |record_id, outcome|
      if outcome['status'] == 'success'
        ids << record_id
      end
    end
    ids
  end
end
