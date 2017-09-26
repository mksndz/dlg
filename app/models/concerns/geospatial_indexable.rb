module GeospatialIndexable
  extend ActiveSupport::Concern

  GEORGIA_COUNTY_REGEX = /United States, Georgia, (\w*|\w*\s\w*) County/

  def counties
    counties = []
    dcterms_spatial.each do |s|
      if s.is_a?(String) && s.match(GEORGIA_COUNTY_REGEX)
        counties << s.match(GEORGIA_COUNTY_REGEX).captures
      end
    end
    counties.flatten
  end

  def has_coordinates?
    dcterms_spatial.each do |s|
      return true if element_has_coordinates s
    end
    false
  end

  def geojson
    multiple_geojson_objects = []
    coordinates(true).each_with_index do |c, i|
      multiple_geojson_objects << %({"type":"Feature","geometry":{"type":"Point","coordinates":[#{c}]},"properties":{"placename":"#{placename[i]}"}})
    end
    multiple_geojson_objects
  end

  def placename
    # return ['No Location Information Available'] unless dcterms_spatial.first and dcterms_spatial.first.is_a? String
    dcterms_spatial.map do |e|
      if e =~ coordinates_regex
        e.gsub(coordinates_regex, '').chop.chop
      else
        'No Location Information Available'
      end
    end
  end

  # return first set of discovered coordinates, or a silly spot if none found
  # todo: figure out a way to not index a location for items with no coordinates
  def coordinates(alt_format = false)
    coordinates_array = []
    if alt_format
      return ['-80.394617, 31.066399'] unless has_coordinates?
      dcterms_spatial.each do |el|
        coordinates_array << "#{longitude(el)}, #{latitude(el)}" if element_has_coordinates el
      end
    else
      return ['31.066399, -80.394617'] unless has_coordinates?
      dcterms_spatial.each do |el|
        coordinates_array <<  "#{latitude(el)}, #{longitude(el)}" if element_has_coordinates el
      end
    end
    coordinates_array
  end

  private


  def latitude(el)
    el.match(coordinates_regex)[1]
  end

  def longitude(el)
    el.match(coordinates_regex)[2]
  end

  def element_has_coordinates(e)
    coordinates_regex === e
  end

  def coordinates_regex
    /(-?\d+\.\d+), (-?\d+\.\d+)/
  end

end