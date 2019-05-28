# CollectionResource is intended for display in the public site as
# supplemental information for a collection
class CollectionResource < ActiveRecord::Base
  belongs_to :collection, counter_cache: true



  default_scope { order position: :asc }

  validates_presence_of :slug
  validates_presence_of :title
  validates_presence_of :raw_content
  validates_presence_of :collection_id

  # scrubs `scrubbed_content` using the :prune scrubber
  html_fragment :scrubbed_content, scrub: :prune

  def raw_content=(value)
    self.scrubbed_content = value
    super value
  end
end
