# frozen_string_literal: true

# perform remediation action to update an Item multivalued field
class RemediationService
  extend ActiveRecord::ConnectionAdapters::PostgreSQL::Quoting

  # create service object and lookup Items to update
  # @param [RemediationAction] remediation_action
  # @return [Boolean]
  def self.prepare(action)
    return unless action.valid?

    lookup_items_for action
  end

  # perform update using a single query
  # @return [RemediationAction]
  def self.run(action)
    field = safe_field_from action
    items = Item.where(id: action.items)
    items.update_all(["#{field} = array_replace(#{field}, ?, ?)",
                      action.old_text, action.new_text])
    action.performed_at = Time.zone.now
    action.save
    Sunspot.index(items)
    Sunspot.commit
  end

  # looks up Items matching remediation params and sets items on the @action
  # @return [TrueClass, FalseClass]
  def self.lookup_items_for(action)
    field = safe_field_from action
    items = Item.where("? = ANY(#{field})", action.old_text)
    return if items.empty?

    action.items = items.pluck :id
    action.save
  end

  # @param [RemediationAction] action
  # @returns [String] column name
  def self.safe_field_from(action)
    quote_column_name(action.field).delete('"')
  end
end
