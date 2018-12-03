# represent a Page: an optional component of an Item
class Page < ActiveRecord::Base
  belongs_to :item, counter_cache: true
  validates :number, presence: true
  validates :number, uniqueness: { scope: :item }
end
