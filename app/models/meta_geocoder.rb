# handle geocoding lookups
class MetaGeocoder
  def self.lookup(spatial_value)
    results = Geocoder.search spatial_value
    return nil unless results.any?

    results.first.coordinates.join ', '
  end
end