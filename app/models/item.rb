class Item < ActiveRecord::Base
  include Slugged
  include ItemIndexing

  belongs_to :collection
  has_one :repository, through: :collection

  def title
    dc_title.first
  end

end
