# represent a Page: an optional component of an Item
class Page < ActiveRecord::Base
  belongs_to :item, counter_cache: true

  validates_presence_of :number
  validates_uniqueness_of :number, scope: :item
end
