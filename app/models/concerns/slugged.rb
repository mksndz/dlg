module Slugged
  extend ActiveSupport::Concern

  # typical slugs
  # gcfa_gtaa_gtaa88-32-0000016
  # geh_maddox_26
  # zhw_hancockarchives_deeds1

  included do
    validates_presence_of :slug
    validates_uniqueness_of :slug
    # no spaces todo devise a better regex for use here
    validates_format_of :slug, without: /\s/, message: 'is not URL friendly'
  end

end