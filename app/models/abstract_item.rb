class AbstractItem < ActiveRecord::Base

  include Slugged

  belongs_to :collection, counter_cache: true
  has_one :repository, through: :collection

  self.table_name = 'items'

  def title
    dc_title.first
  end

end