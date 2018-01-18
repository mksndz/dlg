class Feature < ActiveRecord::Base
  mount_uploader :image, ImageUploader
  def self.available_areas
    %w(carousel tabs)
  end
end
