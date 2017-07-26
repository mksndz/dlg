# behaviors for models that have a slug attribute
module Slugged
  extend ActiveSupport::Concern
  included do
    validates_presence_of :slug
    validates_format_of :slug, without: %r{[^a-z0-9-]+}, message: 'is not URL friendly'
  end
end