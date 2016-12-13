class Portal < ActiveRecord::Base

  has_many :portal_records

  has_many :items,          through: :portal_records,   source: :portable, source_type: 'Item'
  has_many :collections,    through: :portal_records,   source: :portable, source_type: 'Collection'
  has_many :repositories,   through: :portal_records,   source: :portable, source_type: 'Repository'

end