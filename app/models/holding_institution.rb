class HoldingInstitution < ActiveRecord::Base
  has_many :projects
  has_many :collections
end
