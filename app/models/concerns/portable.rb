# shared behavior for entities belonging to a Portal
module Portable
  extend ActiveSupport::Concern

  included do
    # after_update :touch_portable

    has_many :portal_records, as: :portable
    has_many :portals,
             after_remove: :unassign_children,
             after_add: :update_children,
             through: :portal_records do
      # ignore any attempt to add the same portal > 1 time
      def <<(value)
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
    touch
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
    children.update_all(updated_at: Time.now)
    children.each do |c|
      c.portals = c.portals.to_a - [portal]
    end
  end

  def update_children(_)
    touch if persisted?
    case self.class.to_s
    when 'Collection'
      items.update_all(updated_at: Time.now)
    when 'Repository'
      collections.update_all(updated_at: Time.now)
      items.update_all(updated_at: Time.now)
    end
    true
  end

end