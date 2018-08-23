class HoldingInstitution < ActiveRecord::Base
  belongs_to :repository
  has_many :projects
  has_and_belongs_to_many :collections
  mount_uploader :image, ImageUploader
end
