module Slugged
  extend ActiveSupport::Concern

  included do
    validates_presence_of :slug
    validates_format_of :slug, without: %r{\s|:|\/|\\}, message: 'is not URL friendly'
    before_save { slug.downcase! }
  end


end