class Feature < ActiveRecord::Base
  mount_uploader :image, ImageUploader
end
