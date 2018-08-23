class HoldingInstitution < ActiveRecord::Base
  include Portable
  belongs_to :repository
  has_many :projects
  has_and_belongs_to_many :collections
end
