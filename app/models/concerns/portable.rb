module Portable
  extend ActiveSupport::Concern

  included do

    has_many :portal_records, as: :portable
    has_many :portals, after_remove: :unassign_children, through: :portal_records do
      # ignore any attempt to add the same portal > 1 time
      def << (value)
        return self if include? value
        super value
      end
    end
    validates_presence_of :portals, message: I18n.t('activerecord.errors.messages.portal')
  end

  def portal_names
    portals.map(&:name)
  end

  def portal_codes
    portals.map(&:code)
  end

  private

  def unassign_children(portal)
    case self.class.to_s
    when 'Collection'
      remove_from items, portal
    when 'Repository'
      remove_from collections, portal
      remove_from items, portal
    end
    true
  end

  def remove_from(children, portal)
    children.each do |c|
      c.portals = c.portals.to_a - [portal]
    end
  end

end