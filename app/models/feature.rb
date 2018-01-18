class Feature < ActiveRecord::Base
  scope :ordered, -> { order(primary: :desc) }
  scope :carousel, -> { ordered.where(area: 'carousel') }
  scope :tabs, -> { ordered.where(area: 'tabs') }
  mount_uploader :image, ImageUploader
  def self.available_areas
    %w(carousel tabs)
  end
  def to_json
    super(options.merge!({ except: :id }))
  end
end