# frozen_string_literal: true

# represent an instance of an ingest of fulltext data
class FulltextIngest < ActiveRecord::Base

  belongs_to :user

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
end
