class Item < ActiveRecord::Base

  belongs_to :collection, counter_cache: true
  has_one :repository, through: :collection

end
