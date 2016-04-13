class BatchItem < ActiveRecord::Base
  include Slugged

  belongs_to :batch
  belongs_to :collection
  belongs_to :item
  has_one :repository, through: :collection

  validates_presence_of :collection, message: ' could not be set'

  def title
    dcterms_title.first
  end


end
