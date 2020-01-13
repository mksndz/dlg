# frozen_string_literal: true

# perform remediation action to update an Item multivalued field
class RemediationService
  include ActiveRecord::ConnectionAdapters::PostgreSQL::Quoting

  # create service object and lookup Items to update
  # @param [RemediationAction] remediation_action
  # @raise InvalidRemediationError
  def initialize(remediation_action)
    @action = remediation_action
    @field = quote_column_name(@action.field).delete('"')
    raise(InvalidRemediationError, 'No Items found to modify!') unless set_items
  end

  # perform update using a single query
  # @return [RemediationAction]
  def run
    Item
      .where(id: @action.items)
      .update_all(
        [
          "#{@field} = array_replace(#{@field}, ?, ?)",
          @action.old_text, @action.new_text
        ]
      )
    @action.performed_at = Time.zone.now
    @action.save
  end

  private

  # looks up Items matching remediation params and sets items on the @action
  # @return [TrueClass, FalseClass]
  def set_items
    field = quote_column_name(@action.field)
    items = Item.where("? = any(#{field})", @action.old_text)
    if items.any?
      @action.items = items.pluck(:id)
      @action.save
      true
    else
      false
    end
  end
end