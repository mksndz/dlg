# CollectionResource is intended for display in the public site as
# supplemental information for a collection
class CollectionResource < ActiveRecord::Base
  belongs_to :collection
end
