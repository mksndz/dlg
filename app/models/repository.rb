class Repository < ActiveRecord::Base
  include Slugged

  has_many :collections, dependent: :destroy
  has_many :items, through: :collections
  has_and_belongs_to_many :users

  validates_presence_of :title
  validate :coordinates_format

  searchable do

    string :slug, stored: true
    string :record_id, stored: true

    # set empty proxy id field so sunspot knows about it
    # value is set prior to save
    # sunspot search will not work without this, but indexing will
    # see monkeypatch @ config/initializers/sunspot_indexer_id.rb
    string :sunspot_id, stored: true do
      ''
    end

    string :title, stored: true
    string :short_description, stored: true
    string :description, stored: true

    text :title
    text :short_description
    text :description

    string :coordinates, stored: true

    boolean :teaser
    boolean :public
    boolean :dpla

  end

  def record_id
    slug
  end

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
