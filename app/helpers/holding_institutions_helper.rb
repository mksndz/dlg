# useful stuff for working with holding institutions
module HoldingInstitutionsHelper
  HOLDING_INSTITUTION_TYPES = [
    'Archives',
    'Community College',
    'Consortia',
    'Corporate archives',
    'County agencies',
    'County archives',
    'Encyclopedias',
    'Federal agencies',
    'Federal archives',
    'Federal museums',
    'High Schools',
    'Historical Societies',
    'International',
    'Municipal agencies',
    'Municipal archives',
    'Museums',
    'Newspaper archives',
    'Presidential libraries',
    'Private collections',
    'Public libraries',
    'Publishers',
    'Society/foundation archives/libraries',
    'State agencies',
    'State archives',
    'State museums',
    'State libraries',
    'State/National parks',
    'Theological organizations',
    'University archives',
    'University departments',
    'University libraries',
    'University museums'
  ].freeze

  HARVEST_STRATEGIES = %w[
    Other
    OAI-PMH
    ResourceSync
    None
  ].freeze
end
