class PortalRecord < ActiveRecord::Base

  belongs_to :portal
  belongs_to :portable, polymorphic: true

end