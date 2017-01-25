module Portable
  extend ActiveSupport::Concern

  included do

    has_many :portal_records, as: :portable
    has_many :portals, through: :portal_records do
      # ignore any attempt to add the same portal > 1 time
      def << (value)
        return self if self.include? value
        super value
      end
    end

  end

  def portal_names
    portals.map(&:name)
  end

  def portal_codes
    portals.map(&:code)
  end

end