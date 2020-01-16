# frozen_string_literal: true

# represent an occurrence of a remediation action
class RemediationAction < ActiveRecord::Base
  include RemediationActionsHelper

  belongs_to :user
  validates :old_text, presence: true
  validates :new_text, presence: true
  validates :field, presence: true
  validates_inclusion_of :field, in: :available_fields
end
