class BatchImport < ActiveRecord::Base

  belongs_to :batch
  belongs_to :user

  def completed?
    !!(failed || added)
  end

end
