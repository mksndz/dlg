# CollectionResource is intended for display in the public site as
# supplemental information for a collection
class CollectionResource < ActiveRecord::Base
  belongs_to :collection, counter_cache: true

  default_scope { order position: :asc }

  validates_presence_of :slug
  validates_presence_of :title
  validates_presence_of :content
  validates_presence_of :collection_id
end
