# frozen_string_literal: true

# useful stuff for working with remediation actions
module RemediationActionsHelper
  # @return [Array<String (frozen)>]
  def available_fields
    %w[
      dcterms_publisher
      dcterms_creator
      dcterms_contributor
      dcterms_subject
      dlg_subject_personal
      dc_date
      dcterms_temporal
      dcterms_spatial
      dc_format
      dc_right
      dcterms_type
      dc_relation
      dcterms_medium
      dcterms_language
    ]
  end
end
