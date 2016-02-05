module Slugged
  extend ActiveSupport::Concern

  included do
    validates_presence_of :slug
    validates_uniqueness_of :slug
    # todo fix validates_format_of :slug, without: /[^\w\/]|[!\(\)\.]+/, message: 'is not URL friendly'
  end

end