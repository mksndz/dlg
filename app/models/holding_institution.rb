class HoldingInstitution < ActiveRecord::Base
  include Portable

  has_many :projects
  has_and_belongs_to_many :collections
end
