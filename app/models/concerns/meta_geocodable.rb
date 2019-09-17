module MetaGeocodable
  extend ActiveSupport::Concern
  included do
    after_save :lookup_coordinates
  end

  private

  def lookup_coordinates
    return unless dcterms_spatial_changed?

    with_coordinates = []
    dcterms_spatial.each do |spatial|
      if spatial =~ /(-?\d+\.\d+), (-?\d+\.\d+)/
        with_coordinates << spatial
        next
      end
      match_found = false
      # lookup in existing records
      get_matches_with_coordinates(spatial).each do |v|
        next unless v['spatial'][0..-25] == spatial

        with_coordinates << v['spatial']
        match_found = true
      end
      next if match_found

      # lookup using Geocoder
      coordinates = MetaGeocoder.lookup spatial
      with_coordinates << if coordinates
                            "#{spatial}, #{coordinates}"
                          else
                            spatial
                          end
    end
    update_columns dcterms_spatial: with_coordinates
  end

  # Looks only in Item for existing values...
  def get_matches_with_coordinates(spatial_term)
    Item.connection.select_all("
      SELECT DISTINCT * FROM (
        SELECT unnest(dcterms_spatial) spatial FROM items
      ) s WHERE spatial LIKE $$#{spatial_term}%, %.%, %.%$$;
    ")
  end
end