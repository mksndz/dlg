module Slugged
  extend ActiveSupport::Concern

  included do
    validates_presence_of :slug
    # no spaces todo devise a better regex for use here
    validates_format_of :slug, without: /\s/, message: 'is not URL friendly'
    before_save { slug.downcase! }
  end


end