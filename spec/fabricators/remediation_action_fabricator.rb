# frozen_string_literal: true

require 'faker'

Fabricator(:remediation_action) do
  field 'dcterms_subject'
  old_text 'old_text'
  new_text 'new_text'
  user
  items [1, 2]
end