class Repository < ActiveRecord::Base
  include Slugged

  has_many :collections, dependent: :destroy
  has_many :items, through: :collections
  has_and_belongs_to_many :users

  validates_presence_of :title
  validate :coordinates_format

  private

  def coordinates_format
    return false unless coordinates
    lat, lon = coordinates.split(', ')
    begin
      lat = Float(lat)
      lon = Float(lon)
      if lat < -90 || lat > 90 || lon < -180 || lon > 180
        errors.add(:coordinates, I18n.t('activerecord.errors.messages.repository.coordinates'))
      end
    rescue TypeError, ArgumentError
      errors.add(:coordinates, I18n.t('activerecord.errors.messages.repository.coordinates'))
    end
  end

end
