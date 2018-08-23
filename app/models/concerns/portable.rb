# shared behavior for entities belonging to a Portal
module Portable
  extend ActiveSupport::Concern
  included do
    has_many :portal_records, as: :portable
    has_many :portals,
             before_remove: :no_children_assigned_portal!,
             through: :portal_records do
      # ignore any attempt to add the same portal > 1 time
      def <<(value)
        return self if include? value
        super value
      end
    end
    validate :parent_has_portal_assigned
    validates_presence_of :portals, message: I18n.t('activerecord.errors.messages.portal')
  end

  def portal_names
    portals.map(&:name)
  end

  def portal_codes
    portals.map(&:code)
  end

  private

  def parent_has_portal_assigned
    return unless respond_to?(:parent) && parent
    unless (portals - parent.portals).empty?
      errors.add :portals, I18n.t('activerecord.errors.messages.portals.parent_not_assigned')
    end
  end

  def no_children_assigned_portal!(p)
    case self.class.to_s
    when 'Repository'
      children = PortalRecord.where(
        portable_type: 'Collection',
        portal_id: p.id,
        portable_id: collections.pluck(:id)
      )
      if children.any?
        fail PortalError, "Cant remove Portal because Collection(s) #{children.pluck(:portable_id).join(', ')} remain assigned."
      end
    when 'Collection'
      children = PortalRecord.where(
        portable_type: 'Item',
        portal_id: p.id,
        portable_id: items.pluck(:id)
      )
      if children.any?
        fail PortalError, "Cant remove Portal because Items(s) #{children.pluck(:portable_id).join(', ')} remain assigned."
      end
    else
      return
    end
  end
end